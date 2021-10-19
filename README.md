# Computational efficiency of some microbiome data science techniques in R


## Overview

TreeSummarizedExperiment (tse) and phyloseq (pseq) objects are
alternative containers for microbiome data. It is informative to
evaluate their computational efficiency in terms of varying sample and
feature set sizes.


## Results

See the following experiments for benchmarking results:
* [Melting](experiments/melt_benchmark.Rmd)
* [Transforming](experiments/transform_benchmark.Rmd)
* [Agglomerating](experiments/agglomerate_benchmark.Rmd)
* [Estimating alpha diversity](experiments/alpha_benchmark.Rmd)
* [Estimating beta diversity](experiments/beta_benchmark.Rmd)


## Source code for the experiment

Reproduce the analyses by running the following in R (`experiments/` working directory)

```
source("main.R")
```


The code and results in this repository are open source with [Artistic
License 2.0](LICENSE.md).






