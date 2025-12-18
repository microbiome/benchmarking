# Import libraries
if (!require("BiocManager")) {
    install("BiocManager")
    library("BiocManager")
}
pkgs <- c(
    "bench", "DelayedArray", "mia", "microbiome", "microbiomeDataSets", "philr",
    "phyloseq", "picante", "tidyverse", "speedyseq"
)
temp <- sapply(pkgs, function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        install(pkg)
        library(pkg, character.only = TRUE)
    }
})

# Set seed for reproducibility
set.seed(123)

# Set benchmarking hyperparameters
n_iter <- 10
memory_threshold <- 10000
beta_threshold <- c(1000, 10000)
N <- c(10, 100, 1000, 10000)

# Define class names
classes <- c(tse = "TreeSE", pseq = "phyloseq", spseq = "speedyseq")

# Define method names
methods <- c(
    alpha = "Faith diversity",
    beta = "UniFrac dissimilarity",
    melt = "Melting",
    trans = "PhILR transformation",
    agg = "Family agglomeration"
)

# Import dataset
GTSD <- GrieneisenTSData()
# Agglomerate by Genus to reduce size
GTSD <- mia::agglomerateByRank(GTSD, rank = "Genus")

# Run benchmark for each sample size
benchmark_out <- bench::press(
    N = N,
    {
        # Select a random subset of samples
        tse <- GTSD[, sample(ncol(GTSD), N)]
        # Convert TreeSE to phyloseq
        pseq <- mia::convertToPhyloseq(tse)

        # List expressions to benchmark
        expressions <- list(
            # Estimate faith from phyloseq
            alpha_pseq = quote(picante::pd(samp = t(otu_table(pseq)), tree = phy_tree(pseq))[, 1]),
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

        if (N <= beta_threshold[[1]]) {
            # Estimate unifrac from phyloseq
            expressions[["beta_pseq"]] <- quote(
                phyloseq::UniFrac(pseq)
            )
        } else {
            # Use dummy expression because all results must have the same length
            expressions[["beta_pseq"]] <- quote(1 + 1)
        }

        if (N <= beta_threshold[[2]]) {
            # Estimate unifrac from TreeSE
            expressions[["beta_tse"]] <- quote(
                mia::getDissimilarity(tse, method = "unifrac")
            )
        } else {
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
benchmark_df <- benchmark_out |>
    unnest(c(time, gc)) |>
    dplyr::select(expression, N, time, gc, mem_alloc) |>
    separate_wider_delim(
        cols = expression, delim = "_",
        names = c("method", "object")
    ) |>
    filter(method != "beta" |
        (object == "pseq" & N <= beta_threshold[[1]]) |
        (object == "tse" & N <= beta_threshold[[2]]))

# Summarise benchmarking results with mean time and standard deviation
benchmark_df <- benchmark_df |>
    group_by(method, object, N) |>
    summarise(
        Time = as.numeric(mean(time)), Memory = as.numeric(mean(mem_alloc)),
        TimeSD = sd(time), TimeSE = TimeSD / sqrt(n_iter),
        NoGC = sum(gc == "none"), .groups = "drop"
    ) |>
    mutate(
        method = factor(method, levels = names(methods)),
        object = factor(object, levels = names(classes))
    )

# Write to file
benchmark_df |>
    mutate(Time = as.numeric(Time), Memory = as.numeric(Memory)) |>
    write.csv(file = file.path("data", "benchmark_results.csv"), row.names = FALSE)

pkgs <- c("patchwork", "tidyverse")
temp <- sapply(pkgs, function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        install(pkg)
        library(pkg, character.only = TRUE)
    }
})

classes <- c(tse = "TreeSE", pseq = "phyloseq", spseq = "speedyseq")
methods <- c(
    alpha = "Faith diversity",
    beta = "UniFrac dissimilarity",
    melt = "Melting",
    trans = "PhILR transformation",
    agg = "Family agglomeration"
)

# Import results
benchmark_df <- read.csv(file.path("data", "benchmark_results.csv")) %>%
    mutate(method = factor(method, levels = names(methods)),
           object = factor(object, levels = names(classes)))

# Specify plot layouts
scientific_10 <- function(y) {
    sapply(y, function(z) {
        if (is.na(z)) {
            return(NA)
        } else if (z == 1) {
            return("1")
        } else if (z == 10) {
            return("10")
        } else {
            return(parse(text = paste0("10^", log10(z))))
        }
    })
}

breaks <- benchmark_df[["N"]][log10(benchmark_df[["N"]]) %% 1 == 0] |> unique()

# Visualise benchmarking results: time
p1 <- ggplot(benchmark_df, aes(x = N, y = Time, colour = object)) +
    geom_errorbar(aes(ymin = Time - TimeSE, ymax = Time + TimeSE), width = 0) +
    geom_line() +
    geom_point() +
    scale_x_log10(breaks = breaks, limits = benchmark_df[["N"]] |> range(), labels = scientific_10) +
    scale_y_log10(labels = scientific_10) +
    scale_colour_manual(
        labels = classes,
        values = c("black", "darkgrey", "lightgrey")
    ) +
    facet_grid(. ~ method, labeller = labeller(method = methods)) +
    labs(x = "# Samples", y = "Execution time (s)", colour = "Object") +
    theme_bw() +
    theme(
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 15),
        axis.text.x = element_blank(),
        axis.text.y = element_text(size = 12),
        axis.ticks.x = element_blank(),
        strip.text = element_text(size = 15),
        strip.background = element_blank()
    )
# Visualise benchmarking results: memory
p2 <- ggplot(benchmark_df, aes(x = N, y = Memory / 1e6, colour = object)) +
    geom_line() +
    geom_point() +
    scale_x_log10(breaks = breaks, limits = benchmark_df[["N"]] |> range(), labels = scientific_10) +
    scale_y_log10(labels = scientific_10) +
    scale_colour_manual(
        labels = classes,
        values = c("black", "darkgrey", "lightgrey")
    ) +
    facet_grid(. ~ method,
        labeller = labeller(method = methods)
    ) +
    labs(x = "Sample size (n)", y = "Allocated memory (MB)", colour = "Object") +
    theme_bw() +
    theme(
        axis.title = element_text(size = 15),
        axis.text = element_text(size = 12),
        strip.text = element_blank()
    ) +
    guides(colour = "none")
# Combine results
p <- (p1 / p2) +
    plot_layout(guides = "collect") &
    theme(
        legend.position = "bottom",
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 15),
        legend.key.size = unit(1.2, "cm")
    )

# Save plot to file
ggsave("article/OMA_figure.png", width = 15, height = 7)
