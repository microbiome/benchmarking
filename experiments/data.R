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
library(tidyr)                  # pivot_wider function
library(SingleCellExperiment)   # manipulate tse objects
library(reshape)                # merge_all command
library(knitr)                  # kable
library(phyloseq)               # phyloseq functions
library(speedyseq)              # speedyseq functions
library(stringr)                # str_to_title function
library(microbiome)             # transform functions

# list data sets to run benchmark on
# data_sets <- c("AsnicarF_2021", "SongQAData", "GrieneisenTSData", "HMP_2019_ibdmdb", "LifeLinesDeep_2016", "ShaoY_2019")
data_sets <- c("SongQAData", "HMP_2019_ibdmdb", "ShaoY_2019")
bigdata_set <- "GrieneisenTSData"

# Limit to main ranks to reduce unnecessary computing
ranks <- c("Phylum", "Family", "Species")

# define experimental setup
set.seed(3)

# load tse objects and store them into
# a list of containers
containers <- lapply(data_sets, function (x) {load_dataset(x, ranks)})

# Big data
# bigdata <- load_dataset(bigdata_set, ranks = c("Phylum", "Genus", "ASV"))
bigdata <- load_dataset(bigdata_set, ranks = c("Phylum", "Family", "Genus"))

# list sample sizes for random subsetting
sample_sizes <- c(100, 500, 1000, 1500) #, min(sapply(containers, ncol)))
