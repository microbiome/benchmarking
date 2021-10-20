# Load the data
source("data.R")

# Melting results
rmarkdown::render("melt_benchmark.Rmd", output_format="md_document")  # browse in github
rmarkdown::render("melt_benchmark.Rmd", output_format="pdf_document") # easy view locally


# Other stuff
# rmarkdown::render("speed_comparisons.Rmd", output_format="md_document")

