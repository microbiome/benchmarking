# Load utils functions
source("experiments/funcs.R") 

# load data sets and store them into the list "containers"
# prepare a list of data frames "df" for the data on execution times
source("experiments/data.R")

# render output of "melt_benchmark.R" as a md document
rmarkdown::render("experiments/melt_benchmark.Rmd", output_format = "md_document", output_dir = "reports")
rmarkdown::render("experiments/melt_benchmark.Rmd", output_format = "pdf_document", output_dir = "reports")

# render output as a md document
# rmarkdown::render("experiments/transform_benchmark.R", output_format = "md_document", output_file = "transform_benchmark.md", output_dir = "reports")

# render output as a md document
# rmarkdown::render("experiments/agglomerate_benchmark.R", output_format = "md_document", output_file = "agglomerate_benchmark.md", output_dir = "reports")

# render output as a md document
# rmarkdown::render("experiments/alpha_benchmark.R", output_format = "md_document", output_file = "alpha_benchmark.md", output_dir = "reports")

# render output as a md document
# rmarkdown::render("experiments/beta_benchmark.R", output_format = "md_document", output_file = "beta_benchmark.md", output_dir = "reports")
