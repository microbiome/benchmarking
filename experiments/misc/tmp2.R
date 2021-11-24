# make data frame with Time Ratio of tse to pseq execution time of experiment
df <- df_melt[ , c("Dataset", "Time", "Features", "ObjectType")]
dfsub <- pivot_wider(filter(df, Samples == N, Rank == R), 
                     names_from = c(ObjectType),
                     values_from = Time, Features) %>%
  mutate(Ratio = tse / pseq)

# plot execution time ratio for melting subsets from
# the chosen taxonomic rank and chosen number of samples
df <- dfsub
p <- ggplot(df, aes(x = Features, y = Ratio)) + 
    geom_point() + 
    geom_line() + 
    scale_y_continuous(labels = scales::percent) + 
    geom_hline(aes(yintercept = 1), linetype = 2, color = "gray") + 
    labs(title = "Execution time ratio", 
         x = "Features (N)", 
         y = "Ratio (tse/pseq)",
	 caption = paste("TreeSE/phyloseq running time ratio (Samples:", N, "/ Rank:", R, ")")) 

print(p)