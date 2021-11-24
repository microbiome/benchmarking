# Separate analysis for the largest data set
ind <- which.max(sapply(containers, ncol))
bigdata <- containers[[ind]]

max_sample_size <- ncol(bigdata)
big_sample_sizes <- c(10, 100, 1000, 10000, max_sample_size)
big_df <- make_data_frame(bigdata, length(big_sample_sizes))

# define index and ranks of current data set
len_exp <- length(altExps(bigdata))
big_len_N <- length(big_sample_sizes)
    
# repeat experiment for each taxonomic rank
for (rank in 1:len_exp) {
      
  # extract tse from list of containers
  alt_tse <- altExps(bigdata)[[rank]]
      
  # repeat experiment for each sample size
  for (N in big_sample_sizes) {
        
    # select data sets at least as large as sample_size
    if (ncol(alt_tse) >= N) {
          
      # define index of current sample size
      cur_N <- which(N == big_sample_sizes)
          
      # define df index to store results
      tse_ind <- cur_N + 2 * big_len_N * (rank - 1)
      pseq_ind <- cur_N + big_len_N + 2 * big_len_N * (rank - 1)
          
      # random subsetting
      subset_names <- sample(colnames(alt_tse), N)
      sub_tse <- alt_tse[ , colnames(alt_tse) %in% subset_names]
      sub_pseq <- makePhyloseqFromTreeSummarizedExperiment(sub_tse)
          
      # store features and samples
      big_df$Features[tse_ind] <- nrow(sub_tse)
      big_df$Features[pseq_ind] <- nrow(sub_tse)
      big_df$Samples[tse_ind] <- ncol(sub_tse)
      big_df$Samples[pseq_ind] <- ncol(sub_tse)
          
      # test melting for tse
      big_df$Time[tse_ind] <- transform_tse_exec_time(sub_tse)
      
      # test melting for pseq
      big_df$Time[pseq_ind] <- transform_pseq_exec_time(sub_pseq)
          
    }
        
  }
      
}

df <- big_df %>%
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
