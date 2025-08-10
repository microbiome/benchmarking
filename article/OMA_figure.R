# Import libraries
library(bench)
library(DelayedArray)
library(dplyr)
library(ggplot2)
library(mia)
library(microbiome)
library(microbiomeDataSets)
library(patchwork)
library(philr)
library(phyloseq)
library(picante)
library(speedyseq)
library(tidyr)

# Set seed for reproducibility
set.seed(123)

# Set benchmarking hyperparameters
n_iter <- 10
memory_threshold <- 10000
beta_threshold <- c(1000, 10000)
N <- c(10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000)

# Define class names
classes <- c(tse = "TreeSE", pseq = "phyloseq", spseq = "speedyseq")

# Define method names
methods <- c(alpha = "Faith diversity",
             beta = "UniFrac dissimilarity",
             melt = "Melting",
             trans = "PhILR transformation",
             agg = "Family agglomeration")

# Import dataset
GTSD <- GrieneisenTSData()
# Agglomerate by Genus to reduce size
GTSD <- mia::agglomerateByRank(GTSD, rank = "Genus")
# Convert assay to DelayedMatrix
# assay(GTSD, "counts") <- DelayedArray(assay(GTSD, "counts"))

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
      # Melt speedyseq
      melt_spseq = quote(speedyseq::psmelt(pseq)),
      # Melt TreeSE
      melt_tse = quote(mia::meltSE(tse, add.row = TRUE, add.col = TRUE)),
      # Agglomerate phyloseq
      agg_pseq = quote(phyloseq::tax_glom(pseq, taxrank = "Family")),
      # Agglomerate speedyseq
      agg_spseq = quote(speedyseq::tax_glom(pseq, taxrank = "Family")),
      # Agglomerate TreeSE
      agg_tse = quote(mia::agglomerateByRank(tse, rank = "Family"))
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
      memory = if (N <= memory_threshold) TRUE else FALSE,
      check = FALSE,
      exprs = expressions
    )
  }
)

# Retrieve benchmarking results for each experiment and iteration
benchmark_df <- benchmark_out %>%
  unnest(c(time, gc)) %>%
  dplyr::select(expression, N, time, gc, mem_alloc) %>%
  separate_wider_delim(cols = expression, delim = "_",
                       names = c("method", "object")) %>%
  filter(method != "beta" |
           (object == "pseq" & N <= beta_threshold[[1]]) |
           (object == "tse" & N <= beta_threshold[[2]]))

# Write to file
benchmark_df %>%
  mutate(time = as.numeric(time), mem_alloc = as.numeric(mem_alloc)) %>%
  write.csv(file = "article/benchmark_rawdata.csv", row.names = FALSE)

# benchmark_df <- read.csv("article/benchmark_rawdata.csv") %>%
#   mutate(time = as_bench_time(time), mem_alloc = as_bench_bytes(mem_alloc),
#          method = factor(method, levels = names(methods)),
#          object = factor(object, levels = names(classes)))

# Summarise benchmarking results with mean time and standard deviation
benchmark_df <- benchmark_df %>%
  group_by(method, object, N) %>%
  # filter(if( sum(gc == "none") >= 0 ) gc == "none" else TRUE) %>%
  summarise(Time = mean(time), Memory = as_bench_bytes(mean(mem_alloc)),
            TimeSD = sd(time), TimeSE = TimeSD / sqrt(n_iter),
            Count = n(), .groups = "drop") %>%
  mutate(method = factor(method, levels = names(methods)),
         object = factor(object, levels = names(classes)))

# Write to file
benchmark_df %>%
  mutate(Time = as.numeric(Time), Memory = as.numeric(Memory)) %>%
  write.csv(file = "article/benchmark_results.csv", row.names = FALSE)

# benchmark_df <- read.csv("article/benchmark_results.csv") %>%
#   mutate(Time = as_bench_time(Time), Memory = as_bench_bytes(Memory),
#          method = factor(method, levels = names(methods)),
#          object = factor(object, levels = names(classes)))

time_breaks <- as_bench_time(c("10ms", "100ms", "1s", "10s", "100s"))
byte_breaks <- as_bench_bytes(c("1MB", "10MB", "100MB", "1GB", "10GB"))

# Visualise benchmarking results
p1 <- ggplot(benchmark_df, aes(x = N, y = Time, colour = object)) +
  geom_errorbar(aes(ymin = Time - TimeSE, ymax = Time + TimeSE), width = 0) +
  geom_line() +
  geom_point() +
  scale_x_log10(breaks = N, limits = c(N[[1]], N[[length(N)]])) +
  scale_y_bench_time(breaks = time_breaks) +
  scale_colour_manual(labels = classes,
                      values = c("black", "darkgrey", "lightgrey")) +
  facet_grid(. ~ method,
             labeller = labeller(method = methods)) +
  labs(x = "# Samples", y = "Execution time (t)", colour = "Object") +
  theme_bw() +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        strip.background = element_blank())
  
p2 <- ggplot(benchmark_df, aes(x = N, y = Memory, colour = object)) +
  geom_line() +
  geom_point() +
  scale_x_log10(breaks = N, limits = c(N[[1]], N[[length(N)]])) +
  scale_y_bench_bytes(breaks = byte_breaks) +
  scale_colour_manual(labels = classes,
                      values = c("black", "darkgrey", "lightgrey")) +
  facet_grid(. ~ method,
             labeller = labeller(method = methods)) +
  labs(x = "Sample size (n)", y = "Allocated memory (m)", colour = "Object") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        strip.text = element_blank()) +
  guides(colour = "none")

p <- (p1 / p2) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

# Save plot to file
ggsave("article/OMA_figure.png",
       width = 15,
       height = 7)
