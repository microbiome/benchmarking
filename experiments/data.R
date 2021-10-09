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

# define data sets
data_sets <- c("AsnicarF_2017", "GlobalPatterns", "VincentC_2016", "SilvermanAGutData", "SongQAData", "SprockettTHData", "GrieneisenTSData")

# set seed and define sample size
set.seed(3)
sample_size <- 100

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
