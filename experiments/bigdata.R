# Separate analysis for the largest data set
ind <- which.max(sapply(containers, ncol))
df_benchmark_bigdata <- experiment_benchmark(containers[ind],
                            datasetlist[ind],
			    tests[[testmethod]]$tse,
			    tests[[testmethod]]$pseq,
    sample_sizes=c(10, 100, 1000, 10000, ncol(containers[[ind]])))


%>%
           merge_all() %>%   
	   filter(!is.na(Time))

# This outputs non-unique Rank-Feature combinations, which is unexpected.
# TODO: find out the reason and fix?
#> df_benchmark_bigdata[[1]] %>% select(Rank, Features, Samples)  %>% unique()
#     Rank Features Samples
#1  Phylum       12      10
#11 Phylum       18      10


df <- df_benchmark_bigdata %>%
      select(Features, Samples, Rank, ObjectType, Time)  %>% 
      pivot_wider(names_from = c(ObjectType), values_from = Time) %>% 
      mutate(Ratio = tse / pseq) 

p <- ggplot(df, aes(x = Samples, y = Ratio, group = Rank, color = Features)) + 
    geom_point() + 
    geom_line() +
    labs(title = "Relative difference in execution times",
         x = "Samples (N)",
         y = "Relative time (TreeSE / phyloseq)",
         color = "Features (N)",
         caption = "Execution time ratio by samples (TreeSE/phyloseq)") +
    scale_x_log10() +
    geom_hline(yintercept = 1, linetype = 2) 

print(p)


