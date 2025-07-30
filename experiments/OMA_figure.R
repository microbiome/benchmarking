library(bench)
library(dplyr)
library(ggplot2)
library(mia)
library(microbiome)
library(microbiomeDataSets)
library(patchwork)
library(phyloseq)
library(picante)
library(tidyr)

# N <- c(100, 200, 300)
# N <- c(100, 500, 1000)
N <- c(100, 500, 1000, 5000, 10000)
n_iter <- 10

GTSD <- GrieneisenTSData()

benchmark_out <- bench::press(
  N = N,
  {
    tse <- GTSD[ , sample(ncol(GTSD), N)]
    pseq <- convertToPhyloseq(tse)
    
    expressions <- list(
      # Estimate faith from phyloseq
      alpha_pseq = quote(picante::pd(samp = t(otu_table(pseq)), tree = phy_tree(pseq))[ , 1]),
      # Estimate faith from TreeSE
      alpha_tse = quote(mia::getAlpha(tse, index = "faith_diversity")),
      # Melt phyloseq
      melt_pseq = quote(phyloseq::psmelt(pseq)),
      # Melt TreeSE
      melt_tse = quote(mia::meltSE(tse, add.row = TRUE, add.col = TRUE)),
      # Agglomerate phyloseq
      agglomerate_pseq = quote(phyloseq::tax_glom(pseq, taxrank = "Phylum")),
      # Agglomerate TreeSE
      agglomerate_tse = quote(mia::agglomerateByRank(tse, rank = "Phylum"))
    )
    
    if( N <= 1000 ){
      
      # philr transform phyloseq
      expressions[["transform_pseq"]] <- quote(
        philr::philr(t(otu_table(pseq)), tree = phy_tree(pseq), pseudocount = 1)
      )
      
      # philr transform TreeSE
      expressions[["transform_tse"]] <- quote(
        mia::transformAssay(tse, method = "philr", MARGIN = 1L, pseudocount = 1)
      )
      
      # Estimate unifrac from phyloseq
      expressions[["beta_pseq"]] = quote(
        phyloseq::UniFrac(pseq)
      )
      
      # Estimate unifrac from TreeSE
      expressions[["beta_tse"]] <- quote(
        mia::getDissimilarity(tse, method = "unifrac")
      )
      
    }
    
    bench::mark(
      iterations = n_iter,
      check = FALSE,
      exprs = expressions
    )
  }
)

benchmark_df <- benchmark_out %>%
  unnest(c(time, gc)) %>%
  separate_wider_delim(cols = expression, delim = "_",
                       names = c("method", "object")) %>%
  group_by(method, object, N) %>%
  summarise(Time = mean(time), Memory = mean(mem_alloc),
            TimeSD = sd(time), MemorySD = sd(mem_alloc),
            .groups = "drop")

write.csv(benchmark_df,
          file = "benchmark_results.csv",
          row.names = FALSE)

p1 <- ggplot(benchmark_df, aes(x = N, y = Time, colour = object)) +
  geom_errorbar(aes(ymin = Time - TimeSD, ymax = Time + TimeSD), width = 10) +
  geom_line() +
  geom_point() +
  scale_x_continuous(breaks = N) +
  facet_grid(method ~ .) +
  labs(y = "Time", colour = "Object") +
  theme_bw()

p2 <- ggplot(benchmark_df, aes(x = N, y = Memory, colour = object)) +
  geom_errorbar(aes(ymin = Memory - MemorySD, ymax = Memory + MemorySD), width = 10) +
  geom_line() +
  geom_point() +
  scale_x_continuous(breaks = N) +
  facet_grid(method ~ ., scales = "free_y") +
  labs(y = "Allocated Memory", colour = "Object") +
  theme_bw()

p <- (p1 | p2) +
  plot_layout(guides = "collect")

p
