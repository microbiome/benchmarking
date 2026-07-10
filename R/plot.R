# Import libraries
if (!require("BiocManager")) {
    install.packages("BiocManager")
    library("BiocManager")
}

pkgs <- c("patchwork", "tidyverse", "tools")

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
    list.files("out", full.names = TRUE, recursive = TRUE),
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

# Summarise benchmarking results with mean time and standard deviation
df <- df |>
    group_by(method, object, rows, cols) |>
    summarise(
        Count = n(),
        Time = mean(time), TimeSD = sd(time),
        TimeSE = ifelse(Count == 1L, 0, TimeSD / sqrt(Count)),
        Memory = mean(memory / 1e6), MemorySD = sd(memory / 1e6),
        MemorySE = ifelse(Count == 1L, 0, MemorySD / sqrt(Count)),
        .groups = "drop"
    ) |>
    mutate(
        method = factor(method, levels = names(methods)),
        object = factor(object, levels = names(classes))
    )

# Store results table
write.table(df, "inst/extdata/benchmark.tsv", sep = "\t", row.names = FALSE)

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

col.breaks <- unique(df$cols[log10(df$cols) %% 1 == 0])

text_col <- get_theme()$axis.text$colour

cus_theme <- theme(
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

# Visualise benchmarking results: time
plot_bench <- function(df, bench.var){
    
    var_name <- toTitleCase(bench.var)
    df$Mean <- df[[var_name]]
    df$SE <- df[[paste0(var_name, "SE")]]
    
    axis_title <- switch(
        bench.var,
        time = "Execution time (s)",
        memory = "Allocated memory (MB)"
    )
    
    y.breaks <- switch(
        bench.var,
        time = 10^seq(-1, 3),
        memory = 10^seq(0, 4)
    )
    
    y.lims <- range(y.breaks)
    y.lims <- c(min(y.lims[1], min(df$Mean)), max(y.lims[2], max(df$Mean)))
    
    row.breaks <- unique(df$rows[log10(df$rows) %% 1 == 0])
    df$rows <- scientific_10(df$rows)
    
    p <- ggplot(df, aes(x = cols, y = Mean, colour = object)) +
        geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE), width = 0) +
        geom_line() +
        geom_point() +
        scale_x_log10(breaks = col.breaks, limits = range(df$cols), labels = label_scientific) +
        scale_y_log10(
            labels = label_scientific,
            breaks = y.breaks,
            limits = y.lims,
            sec.axis = sec_axis(~ ., name = "# Features")) +
        scale_colour_manual(
            labels = classes,
            values = c("black", "darkgrey", "lightgrey", "red")
        )
    
    grid_by <- ". ~ method"
    grid_lab <- list(method = methods)
    
    if( length(row.breaks) > 1L ){
        grid_by <- sub(".", "rows", grid_by, fixed = TRUE)
        grid_lab[["rows"]] <- label_parsed
    }
    
    p <- p +
        facet_grid(
            as.formula(grid_by),
            labeller = do.call(labeller, grid_lab)
        )
    
    p <- p +
        labs(x = "# Samples", y = axis_title, colour = "Object") +
        theme_bw() +
        cus_theme
    
    return(p)
}

# Visualise benchmarking results
p1 <- plot_bench(df, "time")
p2 <- plot_bench(subset(df, Memory <= 1e3 * 16), "memory")

# Combine results
p <- (p1 / p2) +
    plot_layout(guides = "collect") &
    cus_theme

# Save plot to file
ggsave("inst/assets/benchmark.png", width = 230, height = 300, units = "mm")
