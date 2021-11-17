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


### FUNCTION TO TEST MELTING FOR TSE OBJECT ###
melt_tse_exec_time <- function(tse) {
  
  start.time1 <- Sys.time()
  molten_tse <- mia::meltAssay(tse,
                               add_row_data = TRUE,
                               add_col_data = TRUE)
  end.time1 <- Sys.time()
  
  return(end.time1 - start.time1)
  
}

### FUNCTION TO TEST MELTING FOR TSE OBJECT ###
melt_pseq_exec_time <- function(pseq) {
  
  start.time2 <- Sys.time()
  molten_pseq <- phyloseq::psmelt(pseq)
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}


### FUNCTION TO LOAD DATASETS ###
load_dataset <- function(data_set) {
  
  # create placeholders for working variables
  tse <- TreeSummarizedExperiment()
  tmp <- list()
  
  # define minimal number of features an altExp should contain
  min_features <- 10
  
  # load mia
  if (data_set == "GlobalPatterns") {
    
    mapply(data, list = data_set, package = "mia")
    tse <- eval(parse(text = data_set))
    
    # load microbiomeDataSets
  } else if (data_set %in% c("SilvermanAGutData", "SongQAData", "SprockettTHData", "GrieneisenTSData")) {
    
    tse <- eval((parse(text = paste0("microbiomeDataSets::", data_set, "()"))))
    
    if (data_set == "GrieneisenTSData") {
      
      rowData(tse) <- DataFrame(lapply(rowData(tse), unfactor))
      
    }
    
    # load curatedMetagenomicData
  } else if (data_set %in% c("AsnicarF_2017", "VincentC_2016", "BackhedF_2015", "ZeeviD_2015")) {
    
    tmp <- curatedMetagenomicData(paste0(data_set, ".relative_abundance"), dryrun = FALSE, counts = TRUE)
    
    tse <- tmp[[1]]
    
    assayNames(tse) <- "counts"
    
  }
  
  altExps(tse) <- splitByRanks(tse)
  
  # select elements of altExps(tse) with at least min_features 
  for (rank in taxonomyRanks(tse)) {
    
    if (nrow(altExps(tse)[names(altExps(tse)) == rank][[1]]) < min_features) {
      
      altExps(tse)[names(altExps(tse)) == rank] <- NULL
      
    }
    
  }
  
  mainExpName(tse) <- data_set
  
  return(tse)
  
}

### FUNCTION TO MAKE DATA FRAME ###
make_data_frame <- function(tse) {
  
  data_set <- mainExpName(tse)
  
  len_exp <- length(altExps(tse))
  
  df <- data.frame(Dataset = rep(data_set, 2 * len_N * len_exp),
                   ObjectType = rep(c("tse", "pseq"), len_exp, each = len_N),
                   Rank = rep(altExpNames(tse), each = 2 * len_N),
                   Features = NA,
                   Samples = NA,
                   Time = NA,
                   Command = NA)
  
  df$Command[df$ObjectType == "tse"] <- "mia::meltAssay"
  df$Command[df$ObjectType == "pseq"] <- "phyloseq::psMelt"
  
  df$Dataset <- df$Dataset %>% stringr::str_replace("\\.1$", "") %>% # Ensure UNIQUE data set name
    factor() # Treat data set as a factor
  
  return(df)
  
}
