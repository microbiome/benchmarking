# Load the data
source("data.R", local = knitr::knit_global())

# Run the first benchmark
rmarkdown::render("melt_benchmark.Rmd", output_format="md_document")

# Run the second benchmark
rmarkdown::render("second.Rmd", output_format="md_document")
