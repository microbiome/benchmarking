

df <- df_melt %>% filter(Rank == "Genus") %>%
                  select(Dataset, Time, Features, Samples, ObjectType) %>%
		  pivot_wider(names_from = c(ObjectType),
                     values_from = Time) %>%
                  mutate(Ratio = tse / pseq) 

p <- ggplot(df, aes(x = Samples, y = Ratio, group=Dataset, color = Features)) + 
    geom_point() + 
    geom_line() +
    labs(title = "Melt",
         x = "Samples (N)",
         y = "Relative execution time (TreeSE / phyloseq)",
         color = "Features (N)",
         caption = "Execution time ratio by samples") +
    scale_y_continuous(label = scales::percent)

print(p)

