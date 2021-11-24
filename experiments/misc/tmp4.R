dfsub <- df %>% filter(!Rank=="Kingdom" & !is.na(Samples) & !is.na(Melt)) %>%
                select(Dataset, Melt, Samples, Features, ObjectType, Rank)

df2 <- pivot_wider(dfsub,
                names_from=c(ObjectType),
	        values_from=c(Melt)) %>%
         mutate(Ratio=tse/pseq)

p4 <- ggplot(df2, aes(x=Rank, y=Ratio, group=Dataset, color=Samples)) +
        geom_point() +
        geom_line() +		
	geom_hline(aes(yintercept=1), linetype=2, color="darkgray") + 	
	labs(title="Taxonomic rank vs. execution time",
	     x="",
	     y="Ratio (tse/pseq)")

print(p4)