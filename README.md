# Computational efficiency of some microbiome data science techniques in R

## Overview 

[TreeSummarizedExperiment](https://www.bioconductor.org/packages/release/bioc/html/mia.html)
(TreeSE) and
[phyloseq](https://www.bioconductor.org/packages/release/bioc/html/phyloseq.html)
(pseq) objects are alternative containers for microbiome data. Here we
evaluate their computational efficiency in terms of varying sample and
feature set sizes.

## Analysis method

Multiple data sets, either in the form of a TreeSE or a phyloseq object, were
processed through a few common [analytical
routines](https://github.com/microbiome/benchmarking/tree/main/experiments):

The data sets were splitted by taxonomic ranks to get variations in
feature counts, while keeping the data set and sample sizes
constant. The execution times were measured and recorded for the
different methods and sample/feature count combinations.
 
## Benchmarking results 

Standard data sets:

* [Melting](reports/melt.md)
* [CLR transformation](reports/transform.md) 
* [Agglomeration to Phylum level](reports/agglomerate.md)
* [Alpha diversity estimation (Shannon)](reports/alpha.md)
* [Beta diversity estimation (Bray-Curtis / MDS)](reports/beta.md)

Big data set:

* [Melting](reports/melt_bigdata.md)
* [CLR transformation](reports/transform_bigdata.md) 
* [Agglomeration to Phylum level](reports/agglomerate_bigdata.md)
* [Alpha diversity estimation (Shannon)](reports/alpha_bigdata.md)

## Benchmarking for OMA

The article subdirectory contains the benchmarking script for the OMA
publication and results as tables and figures.

* [Benchmarking script](article/OMA_figure.R)
* [Raw output](article/benchmark_rawdata.csv)
* [Summarised results](article/benchmark_results.csv)
* [Figure](article/OMA_figure.png)

## How to run this analysis locally

To reproduce the analyses, start R from within your local copy of this repository and run:

```
source("main.R")
```

## License

This work is part of [miaverse](https://microbiome.github.io). The code and
results in this repository are open source with [Artistic License
2.0](LICENSE.md).
