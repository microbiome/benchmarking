# Load the data
source("data.R")

# Melting results
rmarkdown::render("melt_benchmark.Rmd", output_format="md_document")
rmarkdown::render("melt_benchmark.Rmd", output_format="pdf_document")

# Other stuff
# rmarkdown::render("speed_comparisons.Rmd", output_format="md_document")
