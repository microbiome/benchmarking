### FUNCTION TO RUN BENCHMARK ON EXPERIMENTS ###
experiment_benchmark <- function(containers, fun_list, sample_sizes, message = TRUE) {
  
  datasetlist <- list()
  
  for (tseind in seq_along(containers)) {

    tse <- containers[[tseind]]
     
    # make a data frame to store execution times
    df <- make_data_frame(tse, sample_sizes, fun_list)
    
    ind <- 1
    
    # repeat experiment for each taxonomic rank
    for (rank in altExpNames(tse)) {    
      
      # extract tse from list of containers
      alt_tse <- altExps(tse)[[rank]]
      
      # repeat experiment for each sample size
      for (N in sample_sizes) {
        
        # select data sets at least as large as sample_size
        if (ncol(alt_tse) >= N) {

          if (message) {
            message(paste(tseind, rank, N, sep = "/"))
          }

          # message("random subsetting to the desired sample size")          
          sub_tse <- alt_tse[ , sample(ncol(alt_tse), N)]

	  # Convert to phyloseq
          sub_pseq <- makePhyloseqFromTreeSummarizedExperiment(sub_tse)

          # Store feature and sample counts before filtering out
	  # zero rows and cols	 
          df[["tse"]]$Features[ind]  <- nrow(sub_tse)
          df[["pseq"]]$Features[ind] <- nrow(phyloseq::otu_table(sub_pseq))
          df[["tse"]]$Samples[ind]   <- ncol(sub_tse)
          df[["pseq"]]$Samples[ind]  <- ncol(phyloseq::otu_table(sub_pseq))
          
          if (length(fun_list) == 3) {            
            df[["speedyseq"]]$Features[ind] <- nrow(phyloseq::otu_table(sub_pseq))
            df[["speedyseq"]]$Samples[ind] <- ncol(phyloseq::otu_table(sub_pseq))            
          }

          rind <- names(which(rowMeans(assay(sub_tse, "counts") == 0) < 1))
	  cind <- names(which(colMeans(assay(sub_tse, "counts") == 0) < 1))
          sub_tse <- sub_tse[rind, cind]
          
	  rind <- names(which(rowMeans(phyloseq::otu_table(sub_pseq) == 0) < 1))
	  cind <- names(which(colMeans(phyloseq::otu_table(sub_pseq) == 0) < 1))
          sub_pseq <- phyloseq::prune_samples(cind, sub_pseq)
          sub_pseq <- phyloseq::prune_taxa(rind, sub_pseq)	  	  
	  
          # run experiment for tse
          df[["tse"]]$Time[ind] <- fun_list[["tse"]](sub_tse)
          
          # run experiment for pseq
          df[["pseq"]]$Time[ind] <- fun_list[["pseq"]](sub_pseq)
          
          # run experiment for speedyseq
          if (length(fun_list) == 3) {            
            df[["speedyseq"]]$Time[ind] <- fun_list[["speedyseq"]](sub_pseq)          
          }
          
        }
        
        ind <- ind + 1
        
      }
      
    }
    
    # browser() 
    datasetlist[[tseind]] <- df %>% merge_all()
    
  }
  
  # merge results from each data set into one data frame and filter them
  DF <- datasetlist %>% merge_all() %>% 
    filter(!is.na(Time))
  
  return(DF)
  
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

### FUNCTION TO TEST MELTING FOR PSEQ OBJECT ###
melt_pseq_exec_time <- function(pseq) {
  
  start.time2 <- Sys.time()
  molten_pseq <- phyloseq::psmelt(pseq)
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}

### FUNCTION TO TEST MELTING FOR SPEEDYSEQ OBJECT ###
melt_speedyseq_exec_time <- function(speedyseq) {
  
  start.time2 <- Sys.time()
  molten_speedyseq <- speedyseq::psmelt(speedyseq)
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}

### FUNCTION TO TEST TRANSFORMING FOR TSE OBJECT ###
transform_tse_exec_time <- function(tse) {
  
  start.time2 <- Sys.time()
  trans_tse <- mia::transformSamples(tse,
                                     method = "log10",
                                     pseudocount = 1)
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}

### FUNCTION TO TEST TRANSFORMING FOR PSEQ OBJECT ###
transform_pseq_exec_time <- function(pseq) {
  
  start.time2 <- Sys.time()
  trans_pseq <- microbiome::transform(pseq,
                                      transform = "log10p",
                                      target = "sample")
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}

### FUNCTION TO TEST AGGLOMERATING FOR TSE OBJECT ###
agglomerate_tse_exec_time <- function(tse) {
  
  start.time2 <- Sys.time()
  tse_phylum <- agglomerateByRank(tse,
                                  rank = "Phylum",
                                  na.rm = TRUE)
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}

### FUNCTION TO TEST AGGLOMERATING FOR PSEQ OBJECT ###
agglomerate_pseq_exec_time <- function(pseq) {
  
  start.time2 <- Sys.time()
  pseq_phylum <- phyloseq::tax_glom(pseq,
                                    taxrank = "Phylum")
  # na.rm = TRUE by default in tax_glom
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}

### FUNCTION TO TEST AGGLOMERATING FOR SPEEDYSEQ OBJECT ###
agglomerate_speedyseq_exec_time <- function(speedyseq) {
  
  start.time2 <- Sys.time()
  speedyseq_phylum <- speedyseq::tax_glom(speedyseq,
                                    taxrank = "Phylum")
  # na.rm = TRUE by default in tax_glom
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}

### FUNCTION TO TEST ALPHA ESTIMATION FOR TSE OBJECT ###
alpha_tse_exec_time <- function(tse) {
  
  start.time2 <- Sys.time()
  alpha_tse <- mia::estimateDiversity(tse,
                                      index = "shannon",
                                      name = "shannon")
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}

### FUNCTION TO TEST ALPHA ESTIMATION FOR PSEQ OBJECT ###
alpha_pseq_exec_time <- function(pseq) {
  
  start.time2 <- Sys.time()
  alpha_pseq <- microbiome::diversity(pseq,
                                      index = "shannon")
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}

### FUNCTION TO TEST BETA ESTIMATION FOR TSE OBJECT ###
beta_tse_exec_time <- function(tse) {
  
  start.time1 <- Sys.time()
  beta_tse <- scater::runMDS(tse,
                             FUN = vegan::vegdist,
                             name = "MDS_BC",
                             exprs_values = "counts")
  #pcoa_tse <- scater::plotReducedDim(beta_tse, "MDS_BC")
  end.time1 <- Sys.time()
  
  return(end.time1 - start.time1)
  
}

### FUNCTION TO TEST BETA ESTIMATION FOR PSEQ OBJECT ###
beta_pseq_exec_time <- function(pseq) {
  
  start.time2 <- Sys.time()
  beta_pseq <- phyloseq::ordinate(pseq, "MDS", "bray")
  #pcoa_pseq <- phyloseq::plot_ordination(pseq, beta_pseq, type = "samples")
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}

### FUNCTION TO LOAD DATASETS ###
load_dataset <- function(data_set, ranks=NULL) {
  
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
  } else if (data_set %in% c("SongQAData", "GrieneisenTSData")) {
    
    tse <- eval((parse(text = paste0("microbiomeDataSets::", data_set, "()"))))
    
    if (data_set == "GrieneisenTSData") {
      rowData(tse) <- DataFrame(lapply(rowData(tse), unfactor))
    }
    
    # load curatedMetagenomicData
  } else if (data_set %in% c("AsnicarF_2017", "AsnicarF_2021", "HMP_2019_ibdmdb", "LifeLinesDeep_2016", "ShaoY_2019")) {
    
    tmp <- curatedMetagenomicData(paste0(data_set, ".relative_abundance"), dryrun = FALSE, counts = TRUE)
    
    tse <- tmp[[1]]
    
    assayNames(tse) <- "counts"
    
  }
  
  # convert first letter of taxonomic ranks to upper case
  colnames(rowData(tse)) <- str_to_title(colnames(rowData(tse)))
  colnames(rowData(tse)) <- gsub("Asv", "ASV", colnames(rowData(tse)))

  # Include selected ranks only
  if (!is.null(ranks)) {
    rowData(tse) <- rowData(tse)[, ranks]
  }
  # generate alternative experiments by taxonomic rank
  altExps(tse) <- splitByRanks(tse)
  
  # select elements of altExps(tse) with at least min_features 
  for (rank in ranks) {
    
    if (nrow(altExps(tse)[names(altExps(tse)) == rank][[1]]) < min_features) {
      
      altExps(tse)[names(altExps(tse)) == rank] <- NULL
      
    }
    
  }
  
  mainExpName(tse) <- data_set
  
  return(tse)
  
}

### FUNCTION TO MAKE DATA FRAME ###
make_data_frame <- function(tse, sample_sizes, fun_list) {
  
  data_set <- mainExpName(tse)
  len_N <- length(sample_sizes)
  len_exp <- length(altExps(tse))

  dlist <- list()
  for (f in names(fun_list)) {
    d <- data.frame(Dataset = data_set,
                    ObjectType = f,
                    Rank = rep(altExpNames(tse), each = len_N),
                    Samples = rep(sample_sizes, len_exp),
                    Features = NA,
                    Time = NA)

    # Ensure UNIQUE data set name and treat it as a factor
    d$Dataset <- d$Dataset %>% stringr::str_replace("\\.1$", "") %>% factor()

    dlist[[f]] <- d

  }
  
  return(dlist)
  
}
