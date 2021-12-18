# Separate analysis for the largest data set

# define sample sizes
big_sample_sizes <- c(100, 1000, 10000, ncol(bigdata))
#big_sample_sizes <- c(10,20,30)

# run analysis
big_df <- experiment_benchmark(list(bigdata), tests[[testmethod]], big_sample_sizes)
