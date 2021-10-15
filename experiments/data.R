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
library(iterators)              # parallel computing
library(doParallel)             # parallel computing
library(tidyr)                  # pivot_wider function

# define data sets
data_sets <- c("AsnicarF_2017", "GlobalPatterns", "VincentC_2016", "SilvermanAGutData")

# set seed and define sample size
set.seed(3)
sample_sizes <- c(10, 100)
len_N <- length(sample_sizes)

# assign working variables with a placeholder to work with them inside the for loop.
len_set <- length(data_sets)
tse <- TreeSummarizedExperiment()
tmp <- list()

# conditions for the for loop (calculating conditions outside of the for loop improves efficiency)
condition_1 <- data_sets == "GlobalPatterns"
condition_2 <- data_sets %in% c("SilvermanAGutData", "SongQAData", "SprockettTHData", "GrieneisenTSData")
condition_3 <- data_sets == "GrieneisenTSData"
condition_4 <- data_sets %in% c("AsnicarF_2017", "VincentC_2016", "BackhedF_2015", "ZeeviD_2015")
condition_5 <- !(data_sets %in% c("SilvermanAGutData", "GrieneisenTSData"))

numCores <- detectCores() - 1
cl <- makeCluster(numCores)

containers <- foreach (data_set = data_sets) %dopar% {
  
  # define index of current data set
  cur_set <- which(data_sets == data_set)
  
  # load mia
  if (condition_1[cur_set]) {
    
    mapply(data, list = data_set, package = "mia")
    tse <- eval(parse(text = data_set))
    
    # load microbiomeDataSets
  } else if (condition_2[cur_set]) {
    
    tse <- eval((parse(text = paste0(data_set, "()"))))
    
    if (condition_3[cur_set]) {
      rowData(tse) <- DataFrame(lapply(rowData(tse), unfactor))
    }
    
    pseq <- makePhyloseqFromTreeSummarizedExperiment(tse)
    
    # load curatedMetagenomicData
  } else if (condition_4[cur_set]) {
    
    tmp <- curatedMetagenomicData(paste0(data_set, ".relative_abundance"), dryrun = FALSE, counts = TRUE)
    
    tse <- tmp[[1]]
    
  }
  
  tse
  
}

stopCluster(cl)

df <- data.frame(Dataset = rep(data_sets, 2 * len_N),
                 ObjectType = c(rep("tse", len_set * len_N), rep("pseq", len_set * len_N)),
                 Features = rep(NA, 2 * len_set * len_N),
                 Samples = rep(NA, 2 * len_set * len_N),
                 AssayValues = rep("", 2 * len_set * len_N))
df$Dataset <- df$Dataset %>% stringr::str_replace("\\.1$", "") %>% # Ensure UNIQUE data set name
              factor() # Treat data set as a factor
