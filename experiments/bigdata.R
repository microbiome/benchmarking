# Separate analysis for the largest data set

# select largest data set
ind <- which.max(sapply(containers, ncol))
bigdata <- containers[ind]

# define sample sizes
max_sample_size <- ncol(bigdata[[1]])
big_sample_sizes <- c(10, 100, 1000, 10000, max_sample_size)
# big_sample_sizes <- c(200, 300, 400)

# run analysis
big_df <- experiment_benchmark(bigdata, tests[[testmethod]], big_sample_sizes)
