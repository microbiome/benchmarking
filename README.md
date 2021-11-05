# Computational efficiency of some microbiome data science techniques in R

## Overview

TreeSummarizedExperiment (tse) and phyloseq (pseq) objects are
alternative containers for microbiome data. It is informative to
evaluate their computational efficiency in terms of varying sample and
feature set sizes.

## Results

See the following experiments for benchmarking results:
* [Melting](reports/melt_benchmark.md)
* [Transforming](reports/transform_benchmark.md)
* [Agglomerating](reports/agglomerate_benchmark.md)
* [Estimating alpha diversity](reports/alpha_benchmark.md)
* [Estimating beta diversity](reports/beta_benchmark.md)

## Source code for the experiment

Reproduce the analyses by running the following in R:

```
rmarkdown::render("main.Rmd", output_format = "md_document")
```

The code and results in this repository are open source with [Artistic
License 2.0](LICENSE.md).






