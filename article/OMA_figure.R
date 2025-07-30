# Import libraries
library(bench)
library(dplyr)
library(ggplot2)
library(mia)
library(microbiome)
library(microbiomeDataSets)
library(phyloseq)
library(picante)
library(tidyr)

# Set seed for reproducibility
set.seed(123)

# Set benchmarking hyperparameters
n_iter <- 10
beta_threshold <- c(1000, 5000)
N <- c(100, 225, 500, 1000, 2250, 5000, 10000)

# Define method names
methods <- c(alpha = "Faith diversity",
             beta = "UniFrac dissimilarity",
             melt = "Melting",
             trans = "PhILR transformation",
             agglomerate = "Phylum agglomeration")

# Import dataset
GTSD <- GrieneisenTSData()
# Agglomerate by Genus to reduce size
GTSD <- mia::agglomerateByRank(GTSD, rank = "Genus")

# Run benchmark for each sample size
benchmark_out <- bench::press(
  N = N,
  {
    # Select a random subset of samples
    tse <- GTSD[ , sample(ncol(GTSD), N)]
    # Convert TreeSE to phyloseq
    pseq <- mia::convertToPhyloseq(tse)
    
    # List expressions to benchmark
    expressions <- list(
      # Estimate faith from phyloseq
      alpha_pseq = quote(picante::pd(samp = t(otu_table(pseq)), tree = phy_tree(pseq))[ , 1]),
      # Estimate faith from TreeSE
      alpha_tse = quote(mia::getAlpha(tse, index = "faith_diversity")),
      # philr transform phyloseq
      trans_pseq = quote(philr::philr(t(otu_table(pseq)), tree = phy_tree(pseq), pseudocount = 1)),
      # philr transform TreeSE
      trans_tse = quote(mia::transformAssay(tse, method = "philr", MARGIN = 1L, pseudocount = 1)),
      # Melt phyloseq
      melt_pseq = quote(phyloseq::psmelt(pseq)),
      # Melt TreeSE
      melt_tse = quote(mia::meltSE(tse, add.row = TRUE, add.col = TRUE)),
      # Agglomerate phyloseq
      agglomerate_pseq = quote(phyloseq::tax_glom(pseq, taxrank = "Phylum")),
      # Agglomerate TreeSE
      agglomerate_tse = quote(mia::agglomerateByRank(tse, rank = "Phylum"))
    )
    
    if( N <= beta_threshold[[1]] ){
      # Estimate unifrac from phyloseq
      expressions[["beta_pseq"]] = quote(
        phyloseq::UniFrac(pseq)
      )
    }else{
      # Use dummy expression because all results must have the same length
      expressions[["beta_pseq"]] = quote(1 + 1)
    }
    
    if( N <= beta_threshold[[2]] ){
      # Estimate unifrac from TreeSE
      expressions[["beta_tse"]] <- quote(
        mia::getDissimilarity(tse, method = "unifrac")
      )
    }else{
      # Use dummy expression because all results must have the same length
      expressions[["beta_tse"]] <- quote(1 + 1)
    }
    
    # Run benchmark
    bench::mark(
      iterations = n_iter,
      check = FALSE,
      memory = FALSE,
      exprs = expressions
    )
  }
)

# Retrieve benchmarking results for each experiment and iteration
benchmark_df <- benchmark_out %>%
  unnest(c(time, gc)) %>%
  dplyr::select(expression, N, time) %>%
  separate_wider_delim(cols = expression, delim = "_",
                       names = c("method", "object")) %>%
  filter(method != "beta" |
           (object == "pseq" & N <= beta_threshold[[1]]) |
           (object == "tse" & N <= beta_threshold[[2]]))

# Write to file
benchmark_df %>%
  mutate(time = as.numeric(time)) %>%
  write.csv(file = "article/benchmark_rawdata.csv", row.names = FALSE)

# Summarise benchmarking results with mean time and standard deviation
benchmark_df <- benchmark_df %>%
  group_by(method, object, N) %>%
  summarise(Time = mean(time), TimeSD = sd(time),
            TimeSE = TimeSD / sqrt(n_iter),
            .groups = "drop") %>%
  mutate(method = factor(method, levels = names(methods)))

# Write to file
benchmark_df %>%
  mutate(Time = as.numeric(Time)) %>%
  write.csv(file = "article/benchmark_results.csv", row.names = FALSE)

# Visualise benchmarking results
ggplot(benchmark_df, aes(x = N, y = Time, colour = object)) +
  geom_errorbar(aes(ymin = Time - TimeSD, ymax = Time + TimeSD), width = 0) +
  geom_line() +
  geom_point() +
  scale_x_log10(breaks = N, limits = c(N[[1]], N[[length(N)]])) +
  scale_colour_discrete(labels = c("phyloseq", "TreeSE")) +
  facet_grid(method ~ .,
             labeller = labeller(method = methods)) +
  labs(x = "# Samples", y = "Execution Time", colour = "Object") +
  theme_bw()

# Save plot to file
ggsave("article/OMA_figure.png",
       width = 6,
       height = 10)
