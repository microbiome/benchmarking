# Add path to custom libraries (only for CSC)
.libPaths(c("/projappl/project_2014893/project_rpackages_451", .libPaths()))

# Import libraries
if (!require("BiocManager")) {
    install("BiocManager")
    library("BiocManager")
}

pkgs <- c("patchwork", "tidyverse")
temp <- sapply(pkgs, function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        install(pkg)
        library(pkg, character.only = TRUE)
    }
})

# Set sample size
N <- 10^(1:5)

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

# Import results


df_list <- lapply(
    list.files("./out/", full.names = TRUE),
    read.table, sep = "\t", header = TRUE
)

df <- do.call(rbind, df_list)

n_iter <- length(unique(df$state))

# Summarise benchmarking results with mean time and standard deviation
df <- df |>
    group_by(method, object, rows, cols) |>
    summarise(
        Time = mean(time), Memory = mean(memory),
        TimeSD = sd(time), TimeSE = TimeSD / sqrt(n_iter),
        NoGC = sum(gc == "none"), .groups = "drop"
    ) |>
    mutate(
        method = factor(method, levels = names(methods)),
        object = factor(object, levels = names(classes))
    )

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

row.breaks <- df$rows[log10(df$rows) %% 1 == 0] |> unique()
col.breaks <- df$cols[log10(df$cols) %% 1 == 0] |> unique()

# Visualise benchmarking results: time
p1 <- ggplot(df, aes(x = cols, y = Time, colour = object)) +
    geom_errorbar(aes(ymin = Time, ymax = Time), width = 0) +
    geom_line() +
    geom_point() +
    scale_x_log10(breaks = col.breaks, limits = range(df$cols), labels = scientific_10) +
    scale_y_log10(labels = scientific_10) +
    scale_colour_manual(
        labels = classes,
        values = c("black", "darkgrey", "lightgrey")
    ) +
    facet_grid(rows ~ method, labeller = labeller(method = methods)) +
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
p2 <- ggplot(df, aes(x = rows, y = Memory / 1e6, colour = object)) +
    geom_line() +
    geom_point() +
    scale_x_log10(breaks = col.breaks, limits = range(df$rows), labels = scientific_10) +
    scale_y_log10(labels = scientific_10) +
    scale_colour_manual(
        labels = classes,
        values = c("black", "darkgrey", "lightgrey")
    ) +
    facet_grid(cols ~ method,
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
