# Load utils functions
source("experiments/funcs.R")

# load data sets and store them into the list "containers"
# prepare a list of data frames "df" for the data on execution times
source("experiments/data.R")

# Define all tests
tests <- list()
tests[["melt"]] <- c(tse = melt_tse_exec_time,
                     pseq = melt_pseq_exec_time,
                     speedyseq = melt_speedyseq_exec_time)
tests[["agglomerate"]] <- c(tse = agglomerate_tse_exec_time,
                            pseq = agglomerate_pseq_exec_time,
                            speedyseq = agglomerate_speedyseq_exec_time)
tests[["transform"]] <- c(tse = transform_tse_exec_time, pseq = transform_pseq_exec_time)
tests[["alpha"]] <- c(tse = alpha_tse_exec_time, pseq = alpha_pseq_exec_time)
tests[["beta"]] <- c(tse = beta_tse_exec_time, pseq = beta_pseq_exec_time)

# TODO? Other functionality to test..? Tree-based functions? It would then
# be necessary to ensure that all example data sets have tree info.

# Generate reports (go through tests in alphabetical order)

# Standard tests with common sample sizes

for (testmethod in sort(names(tests))) {
  
  print(testmethod)
  
  # Run benchmarking tests
  source("experiments/benchmark_run.R") 
  
  # Report benchmarking tests
  rmarkdown::render("experiments/benchmark.Rmd",
      output_format = "md_document",
      output_file = paste0("../reports/", testmethod, ".md"))

}

# Separate analysis for the big data set
# Ignore beta test, as it gets prohibitively slow with very large sample sizes
for (testmethod in setdiff(sort(names(tests)), "beta")) {

  # Run benchmarking tests
  source("experiments/bigdata.R")
  
  # Report benchmarking tests
  rmarkdown::render("experiments/big_benchmark.Rmd",
      output_format = "md_document",
      output_file = paste0("../reports/", testmethod, "_bigdata", ".md"))

}

