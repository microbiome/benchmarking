

```{r bigdata, echo = FALSE, fig.height = 5, fig.width = 4*length(containers)}
df <- df_benchmark_bigdata %>%
        select(Dataset, Time, Features, Rank, ObjectType) %>%
	unique() %>%
      pivot_wider(names_from = c(ObjectType), values_from = Time) %>% 
      mutate(Ratio = tse / pseq) 

p <- ggplot(df, aes(x = Features, y = Ratio, group = Rank)) + 
    geom_point() + 
    geom_line() +
    labs(title = "Relative difference in execution times",
         x = "Features (N)",
         y = "Relative time (TreeSE / phyloseq)",
         caption = "Execution time ratio by features (TreeSE/phyloseq)") +
    # scale_y_continuous(label = scales::percent) +
    scale_x_log10() +
    geom_hline(yintercept = 1, linetype = 2) 

print(p)
```


```{r ex_time, echo = FALSE, eval=FALSE}
## Execution times vs number of features with fixed number of samples
# plot execution time for melting subsets from
# the taxonomic rank R and with N samples 
p1_melt <- plot_exec_time(df_melt, N, R)
print(p1_melt)
```
