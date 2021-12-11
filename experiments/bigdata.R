# Separate analysis for the largest data set

# select largest data set
ind <- which.max(sapply(containers, ncol))
bigdata <- containers[ind]

# define sample sizes
max_sample_size <- ncol(bigdata)
# big_sample_sizes <- c(10000, max_sample_size)
big_sample_sizes <- c(200, 300)

# run analysis
big_df <- experiment_benchmark(bigdata, tests[[testmethod]], big_sample_sizes)
