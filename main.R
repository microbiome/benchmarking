# Load utils functions
source("experiments/funcs.R")

# load data sets and store them into the list "containers"
# prepare a list of data frames "df" for the data on execution times
source("experiments/data.R")

# Define all tests
tests[["melt"]] <- c(tse = melt_tse_exec_time, pseq = melt_pseq_exec_time)
# Add these one by one making sure that they work
# tests[["transform"]] <- c(tse = transform_tse_exec_time, pseq = transform_pseq_exec_time)
# tests[["agglomerate"]] <- c(tse = agglomerate_tse_exec_time, pseq = agglomerate_pseq_exec_time)
# tests[["alpha"]] <- c(tse = alpha_tse_exec_time, pseq = alpha_pseq_exec_time)
# tests[["beta"]] <- c(tse = beta_tse_exec_time, pseq = beta_pseq_exec_time)

# render output of "melt_benchmark.Rmd" as a md document
for (testmethod in names(tests)) {
  # Define test file names
  testfile <- paste0(testmethod, "_benchmark_run.R")
  testrmd <- paste0("experiments/", testmethod, "_benchmark.Rmd")
  # Run benchmarking tests
  source(testfile) 
  # Report benchmarking tests
  rmarkdown::render(testrmd, output_format = "md_document", output_dir = "reports")
  rmarkdown::render(testrmd, output_format = "pdf_document", output_dir = "reports")
}


