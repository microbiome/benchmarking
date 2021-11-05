### FUNCTION TO RUN BENCHMARK ON EXPERIMENTS ###
experiment_benchmark <- function(containers, df, tse_fun, pseq_fun, sample_sizes) {
  
  for (tse in containers) {
    
    # define index and ranks of current data set
    cur_set <- which(lapply(containers, mainExpName) == mainExpName(tse))
    len_exp <- length(altExps(tse))
    len_N <- length(sample_sizes)
    
    # repeat experiment for each taxonomic rank
    for (rank in 1:len_exp) {
      
      # extract tse from list of containers
      alt_tse <- altExps(tse)[[rank]]
      
      # repeat experiment for each sample size
      for (N in sample_sizes) {
        
        # select data sets at least as large as sample_size
        if (ncol(alt_tse) >= N) {
          
          # define index of current sample size
          cur_N <- which(N == sample_sizes)
          
          # define df index to store results
          tse_ind <- cur_N + 2 * len_N * (rank - 1)
          pseq_ind <- cur_N + len_N + 2 * len_N * (rank - 1)
          
          # random subsetting
          subset_names <- sample(colnames(alt_tse), N)
          sub_tse <- alt_tse[ , colnames(alt_tse) %in% subset_names]
          sub_pseq <- makePhyloseqFromTreeSummarizedExperiment(sub_tse)
          
          # store dimensions
          df[[cur_set]]$Features[tse_ind] <- nrow(sub_tse)
          df[[cur_set]]$Features[pseq_ind] <- nrow(sub_tse)
          df[[cur_set]]$Samples[tse_ind] <- ncol(sub_tse)
          df[[cur_set]]$Samples[pseq_ind] <- ncol(sub_tse)
          
          # test melting for tse
          df[[cur_set]]$Time[tse_ind] <- tse_fun(sub_tse)
          
          # test melting for pseq
          df[[cur_set]]$Time[pseq_ind] <- pseq_fun(sub_pseq)
          
        }
        
      }
      
    }
    
  }
  
  return(df)
  
}



### FUNCTION TO PLOT EXECUTION TIME VS FEATURES ###
plot_exec_time <- function(df, sample_size, rank) {
  # Set breaks for log X scale
  # m <- max(df$Features, na.rm=TRUE); r <- round(m, -(nchar(m)-1))
  # v <- 10^seq(2, log10(r), by=1)
  # v <- c(500, 1000, 2000, 5000, 10000)
  
  v <- unique(na.omit(df$Features))
  
  dfsub <- filter(df, Samples %in% sample_size, Rank %in% rank)
  
  p <- ggplot(dfsub, aes(x = Features, y = Time * 1000, color = Command)) + 
    geom_point() + 
    geom_line() +
    labs(title = paste("Melting comparison (N =", paste(unique(dfsub$Samples), 
                        collapse = ","),
                       "and R =", paste(unique(dfsub$Rank,
                        collapse = ","), ")", sep = "")),
         x = "Features (D)",
         y = "Execution time (ms)",
         color = "Method:",
         caption = "Execution time of melting as a function of number of features") + 
    scale_x_log10(breaks = v, labels = v) + # Log is often useful with sample size
    # scale_y_log10() + # Log is often useful with sample size
    scale_color_manual(values = c("black", "darkgray")) + 
    theme(legend.position = "bottom")
  
  return(p)
  
}



### FUNCTION TO PLOT EXECUTION TIME VS FEATURES ###
plot_ratio <- function(df, sample_size, rank) {
  
  dfsub <- filter(df, Samples %in% sample_size, Rank %in% rank)
  
  dfsub <- pivot_wider(dfsub[ , c("Dataset", "Time", "Features", "ObjectType")] %>% 
                         filter(!is.na(Time)), names_from = c(ObjectType), values_from = Time, Features) %>% 
    mutate(Ratio = tse / pseq)
  
  p <- ggplot(dfsub, aes(x = Features, y = Ratio)) + 
    geom_point() + 
    geom_line() + 
    scale_y_continuous(labels = scales::percent) + 
    geom_hline(aes(yintercept = 1), linetype = 2, color = "gray") + 
    labs(title = "Execution time ratio", 
         x = "Features (N)", 
         y = "Ratio (tse/pseq)")
  
  return(p)
  
}
