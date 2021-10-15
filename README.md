# Computational efficiency of some microbiome data science techniques in R


## Overview

TreeSummarizedExperiment (tse) and phyloseq (pseq) objects are
alternative containers for microbiome data. It is informative to
evaluate their computational efficiency in terms of varying sample and
feature set sizes.


## Results

See [speed comparisons](speed_comparisons.md) for benchmarking results



## Source code for the experiment

Reproduce the analyses by running the following in R:

```
rmarkdown::render("melt_benchmark.Rmd", output_format="md_document")
rmarkdown::render("speed_comparisons.Rmd", output_format="md_document")
```


The code and results in this repository are open source with [Artistic
License 2.0](LICENSE.md).






