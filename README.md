# Benchmarking alternative frameworks for microbiome data science

## Intro

The mia ecosystem of packages in R/Bioconductor is an extensive framework for
modern microbiome data science based on the TreeSummarizedExperiment (TreeSE)
data container. In parallel, alternative frameworks with similar objectives have
also been developed by others, including phyloseq, QIIME 2 and Mothur. While
most frameworks support most routine tasks for microbiome analysis, they might
differ in terms of performance and efficiency. In this repository, we provide an
extensive benchmark between TreeSE/mia, QIIME 2, phyloseq and speedyseq.

## Methods

Comparisons include five routine operations: melting, agglomeration, assay
transformation, alpha and beta diversity estimation. Each operation is applied
to random subsets of samples and features from the Metalog database. Performance
is measured in terms of execution time (s) and allocated memory (MB) over ten
replicates using the bench package.

## Results

Benchmark:
* [Benchmark results](inst/extdata/benchmark.tsv)
* [Benchmarking script](inst/assets/benchmark.png)

Sample composition:
* [Dataset compositions](inst/extdata/composition.tsv)
* [Figures](inst/assets/composition.png)

## Reproducibility

0. Create Apptainer with [build.sh](inst/scripts/build.sh)
1. Create feature/sample subsets with [preprocess.sh](inst/scripts/preprocess.sh)
2. Run benchmark with [array.sh](inst/scripts/array.sh)
4. Visualise results with [plot.R](R/plot.R) and [composition.R](R/composition.R)

Currently, it is required to manually adjust some parameters between the steps.
Technical details are further provided in the corresponding scripts.

## System requirements

Each operation was run on a single node of the CSC Puhti supercomputer cluster
with 4 CPUs and 16 GB RAM. However, larger resources are required to preprocess
the Metalog dataset into feature/sample subsets, especially for QIIME 2. While
the original benchmark was parallelised using SLURM array jobs, it is possible
to perform single operations locally with [single.sh](inst/scripts/single.sh).

## Legacy

The current benchmark was conceived after several iterations in a continuously
developing framework, using the most extensive microbiome data resource to date.

The initial version of the benchmark, which compared only mia and phyloseq based
on multiple smaller datasets of variable size, is available in the
[legacy branch](https://github.com/microbiome/benchmarking/tree/legacy/) of this
repository, and detailed information is provided in the related README.

## License

This work is part of [miaverse](https://microbiome.github.io). The code and
results in this repository are openly accessible under an Artistic License 2.0.
