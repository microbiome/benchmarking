
dfsub <- df %>% filter(!Rank=="Kingdom" & !is.na(Samples) & !is.na(Melt)) %>%
                select(Dataset, Melt, Samples, Features, ObjectType, Rank)

df3 <- pivot_wider(dfsub,
                names_from=c(ObjectType),
	        values_from=c(Melt)) %>%
         mutate(Ratio=tse/pseq)

p3 <- ggplot(df3, aes(x=Samples, y=Ratio, color=Features, group=Rank)) +
        geom_point() +
        geom_line() +
	geom_hline(aes(yintercept=1), linetype=2, color="darkgray") + 	
        facet_grid(Dataset ~ .) + 
	labs(title="Execution time ratio",
	     x="Samples (N)",
	     y="Ratio (tse/pseq)")

print(p3)