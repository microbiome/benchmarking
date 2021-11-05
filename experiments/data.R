# no need to show all code, let us just show the benchmarking results
# code is in the Rmd file for those who want to dig in deeper.
# call packages to load data sets
knitr::opts_chunk$set(message = FALSE, warning = FALSE)

library(ggplot2)                # plotting
theme_set(theme_bw())

library(dplyr)                  # pipe operator
library(mia)                    # data sets and analysis
library(microbiomeDataSets)     # data sets
library(curatedMetagenomicData) # data sets
library(scater)                 # beta diversity
library(parallel)               # parallel computing
library(tidyr)                  # pivot_wider function
library(SingleCellExperiment)   # manipulate tse objects
library(reshape)                # merge_all command

# define experimental setup
data_sets <- c("AsnicarF_2017", "GlobalPatterns", "SongQAData", "GrieneisenTSData") %>% sort()
set.seed(3)
sample_sizes <- c(10, 100, 1000)
len_N <- length(sample_sizes)
numCores <- detectCores() - 1



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
