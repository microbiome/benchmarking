# Import libraries
if (!require("BiocManager")) {
    install.packages("BiocManager")
    library("BiocManager")
}

pkgs <- c("patchwork", "tidyverse")

temp <- sapply(pkgs, function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        install(pkg)
        library(pkg, character.only = TRUE)
    }
})

# Define class names
classes <- c(
    tse = "TreeSE",
    pseq = "phyloseq",
    spseq = "speedyseq",
    qiime = "QIIME 2"
)

# Define method names
methods <- c(
    trans = "PhILR transformation",
    agg = "Family agglomeration",
    alpha = "Faith diversity",
    beta = "UniFrac dissimilarity",
    melt = "Melting"
)

# Import results
df_list <- lapply(
    list.files("./out", full.names = TRUE, recursive = TRUE),
    read.table, sep = "\t", header = TRUE
)

df <- do.call(rbind, df_list)

df <- reshape(
    df,
    idvar = setdiff(names(df), c("var", "value")),
    timevar = "var",
    v.names = "value",
    direction = "wide"
)

names(df) <- sub("value.", "", names(df), fixed = TRUE)

# Set sample size
n_iter <- length(unique(df$state))

# Summarise benchmarking results with mean time and standard deviation
df <- df |>
    group_by(method, object, rows, cols) |>
    summarise(
        Time = mean(time), Memory = mean(memory / 1e6),
        TimeSD = sd(time), TimeSE = TimeSD / sqrt(n_iter),
        .groups = "drop"
    ) |>
    mutate(
        method = factor(method, levels = names(methods)),
        object = factor(object, levels = names(classes))
    )

# Specify plot layouts
scientific_10 <- function(y) {
    sapply(y, function(z) {
        if( is.character(z) ){
            z <- as.numeric(z)
        }
        if( is.na(z) ){
            NA
        }else if( z %in% c(1, 10) ){
            as.character(z)
        }else{
            paste0("10^", log10(z))
        }
    })
}

label_scientific <- function(x) parse(text = scientific_10(x))

row.breaks <- unique(df$rows[log10(df$rows) %% 1 == 0])
col.breaks <- unique(df$cols[log10(df$cols) %% 1 == 0])

df$rows <- scientific_10(df$rows)
text_col <- get_theme()$axis.text$colour

# Visualise benchmarking results: time
p1 <- ggplot(df, aes(x = cols, y = Time, colour = object)) +
    geom_errorbar(aes(ymin = Time, ymax = Time), width = 0) +
    geom_line() +
    geom_point() +
    scale_x_log10(breaks = col.breaks, limits = range(df$cols), labels = label_scientific) +
    scale_y_log10(labels = label_scientific, sec.axis = sec_axis(~ ., name = "# Features")) +
    scale_colour_manual(
        labels = classes,
        values = c("black", "darkgrey", "lightgrey", "red")
    ) +
    facet_grid(
        rows ~ method,
        labeller = labeller(rows = label_parsed, method = methods)
    ) +
    labs(x = "# Samples", y = "Execution time (s)", colour = "Object") +
    theme_bw() +
    theme(
        # axis.title.x = element_blank(),
        # axis.title.y = element_text(size = 15),
        # axis.text.x = element_blank(),
        # axis.text.y = element_text(size = 12),
        # axis.ticks.x = element_blank(),
        legend.position = "bottom",
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 15),
        legend.key.size = unit(1.2, "cm"),
        axis.title = element_text(size = 15),
        axis.text.y.right = element_blank(),
        axis.ticks.y.right = element_blank(),
        axis.text = element_text(size = 12),
        strip.text.x = element_text(size = 15),
        strip.text.y = element_text(colour = text_col, size = 12, angle = 0),
        strip.background = element_blank()
    )

# Visualise benchmarking results: memory
p2 <- ggplot(df, aes(x = cols, y = Memory, colour = object)) +
    geom_line() +
    geom_point() +
    scale_x_log10(breaks = col.breaks, limits = range(df$cols), labels = scientific_10) +
    scale_y_log10(labels = scientific_10) +
    scale_colour_manual(
        labels = classes,
        values = c("black", "darkgrey", "lightgrey")
    ) +
    facet_grid(rows ~ method, labeller = labeller(method = methods)) +
    labs(x = "Sample size (n)", y = "Allocated memory (MB)", colour = "Object") +
    theme_bw() +
    theme(
        axis.title = element_text(size = 15),
        axis.text = element_text(size = 12),
        # strip.text = element_blank()
        strip.background = element_blank()
    )#  +
    # guides(colour = "none")

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



ggplot(df, aes(x = cols, y = Time, colour = ordered(rows))) +
    geom_line() +
    geom_point() +
    scale_x_log10(breaks = col.breaks, limits = range(df$cols), labels = scientific_10) +
    scale_y_log10(labels = scientific_10) +
    scale_colour_grey(start = 0.8, end = 0.2, labels = function(x) scientific_10(as.numeric(x))) +
    facet_grid(
        method ~ object,
        labeller = labeller(method = methods, object = classes)
    ) +
    labs(x = "Sample size (n)", y = "Execution time (s)", colour = "Feature size (m)") +
    theme_bw()


ggplot(df, aes(x = cols, y = Memory, colour = ordered(rows))) +
    geom_line() +
    geom_point() +
    scale_x_log10(breaks = col.breaks, limits = range(df$cols), labels = scientific_10) +
    scale_y_log10(labels = scientific_10) +
    scale_colour_grey(start = 0.8, end = 0.2, labels = function(x) scientific_10(as.numeric(x))) +
    facet_grid(
        method ~ object,
        labeller = labeller(method = methods, object = classes)
    ) +
    labs(x = "Sample size (n)", y = "Allocated memory (MB)", colour = "Feature size (m)") +
    theme_bw()
