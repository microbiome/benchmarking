
# Import libraries
pkgs <- c("dplyr", "ggplot2", "tidyr")

temp <- sapply(pkgs, function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        install.packages(pkg)
        library(pkg, character.only = TRUE)
    }
})

sample_levels <- c("human", "environment", "animal", "ocean")

# Import results
df <- read.table("inst/extdata/metadata.tsv", sep = "\t", header = TRUE)

df <- df |>
    rename(environment = environmental) |>
    pivot_longer(
        cols = all_of(sample_levels),
        names_to = "Name",
        values_to = "Value"
    ) |>
    mutate(Name = factor(Name, levels = rev(sample_levels)))

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

df$rows <- scientific_10(df$rows)
df$cols <- scientific_10(df$cols)

text_col <- get_theme()$axis.text$colour

p <- ggplot(df, aes(x = Value, y = seed, fill = Name)) +
    geom_bar(stat = "identity", orientation = "y") +
    geom_errorbar(
      aes(x = sparsity, ymin = seed - 0.5, ymax = seed + 0.5),
      orientation = "x", width = 0, colour = "darkgrey"
    ) +
    facet_grid(rows ~ cols, switch = "y", labeller = label_parsed) +
    scale_x_continuous(
        breaks = seq(0, 1, by = 1 / 4),
        labels = seq(0, 100, by = 25),
        #expand = 0,
        sec.axis = sec_axis(~ ., name = "# Samples")) +
    scale_fill_discrete(
        palette = c("#CC7A5C", "#009E73", "#8B4513", "#0072B2"),
        limits = sample_levels
    ) +
    labs(x = "Percent composition", y = "# Features", fill = "Sample type") +
    theme_bw() +
    theme(
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 15),
        legend.key.size = unit(0.8, "cm"),
        axis.title = element_text(size = 15),
        axis.text.x.top = element_blank(),
        axis.ticks.x.top = element_blank(),
        axis.text.y.left = element_blank(),
        axis.ticks.y.left = element_blank(),
        strip.text = element_text(size = 12),
        strip.text.y.left = element_text(angle = 0),
        strip.background = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank()
    )

# Save plot to file
ggsave("inst/assets/composition.png", width = 250, height = 200, units = "mm")
