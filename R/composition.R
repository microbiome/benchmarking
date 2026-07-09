
library(dplyr)
library(tidyr)
library(ggplot2)

sample_levels <- c("human", "environment", "animal", "ocean")

# Import results
df_list <- lapply(
    list.files("./metadata", full.names = TRUE),
    read.table, sep = " ", header = TRUE
)

df <- do.call(rbind, df_list)

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

sparsity_df <- df |>
    mutate(sparsity = as.factor(sparsity)) |>
    group_by(seed, rows, cols) |>
    summarise(sparsity = unique(sparsity)) |>
    mutate(sparsity = as.numeric(sparsity))

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
        legend.key.size = unit(1.2, "cm"),
        axis.title = element_text(size = 15),
        axis.text.x.top = element_blank(),
        axis.ticks.x.top = element_blank(),
        axis.text.y.left = element_blank(),
        axis.ticks.y.left = element_blank(),
        strip.text = element_text(size = 12),
        strip.text.y.left = element_text(angle = 0),
        strip.background = element_blank()
    )

# Save plot to file
ggsave("sup_figure.png", width = 250, height = 200, units = "mm")

