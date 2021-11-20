# no need to show all code, let us just show the benchmarking results
# code is in the Rmd file for those who want to dig in deeper.
# call packages to load data sets
knitr::opts_chunk$set(message = FALSE, warning = FALSE)

library(ggplot2)                # plotting
theme_set(theme_bw(20))

library(dplyr)                  # pipe operator
library(mia)                    # data sets and analysis
library(microbiomeDataSets)     # data sets
library(curatedMetagenomicData) # data sets
library(scater)                 # beta diversity
library(parallel)               # parallel computing
library(tidyr)                  # pivot_wider function
library(SingleCellExperiment)   # manipulate tse objects
library(reshape)                # merge_all command

# list data sets to run benchmark on
#data_sets <- c("AsnicarF_2017", "GlobalPatterns", "SongQAData")
data_sets <- "SongQAData"

# list sample sizes for random subsetting
sample_sizes <- c(10, 100, 200, 500, 1000)

# define experimental setup
set.seed(3)
len_N <- length(sample_sizes)
numCores <- detectCores() - 1

# load tse objects and store them into
# a list of containers
containers <- mclapply(data_sets, load_dataset, mc.cores = numCores)
# containers <- lapply(data_sets, load_dataset)

# make a data frame for each tse object
# and store them into a list of data frames
datasetlist <- lapply(containers, make_data_frame)
