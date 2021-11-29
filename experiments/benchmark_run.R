# run benchmark on melting of tse and pseq with custom sample sizes
df_benchmark <- experiment_benchmark(containers,
                                     datasetlist,
                                     tests[[testmethod]]$tse,
                                     tests[[testmethod]]$pseq,
				     sample_sizes) %>%
           merge_all() %>%      # merge results from each data set into one data frame
	   filter(!is.na(Time))



