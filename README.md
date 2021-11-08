# Computational efficiency of some microbiome data science techniques in R

## Overview and Motivation

[TreeSummarizedExperiment](https://www.bioconductor.org/packages/release/bioc/html/mia.html) (tse) and [phyloseq](https://www.bioconductor.org/packages/release/bioc/html/phyloseq.html) (pseq) objects are
alternative containers for microbiome data. It is informative to
evaluate their computational efficiency in terms of varying sample and
feature set sizes.

## Method of the Analysis

Multiple data sets, either in the form of a tse or a pseq object, were processed through a few common [analytical routines](https://github.com/microbiome/benchmarking/tree/RiboRings/experiments):

* Melting the object into a data frame;
* Transforming its absolute counts to a logp10 assay;
* Agglomerating its data by taxonomic rank (Phylum);
* Estimating the alpha diversity within its samples in terms of Shannon Diversity Index;
* Estimating the beta diversity across its samples in terms of Bray-Curtis Dissimilarity with metric Multidimensional Scaling (MDS).

The data sets were splitted by taxonomic ranks into alternative experiments (`altExp`), of which only those with at least 10 features (number of rows) were selected for further analysis. Next, the `altExps` of each data set were randomly subsetted by a variable number of samples (number of rows). These random subsets of the splitted-by-rank datasets underwent the analytical routines, the execution times of which were measured and compared based on object type used for the experiment, whether `tse` or `pseq`.
 
## Results of the Benchmarking

Reports with the results of the benchmarking experiments are listed below:

* [Melting](reports/melt_benchmark.md);
* [Transforming](reports/transform_benchmark.md);
* [Agglomerating](reports/agglomerate_benchmark.md);
* [Estimating alpha diversity](reports/alpha_benchmark.md);
* [Estimating beta diversity](reports/beta_benchmark.md).

## How to run this analysis locally

To reproduce this analysis, start R from within your local copy of this repository and run:

```
rmarkdown::render("main.R", output_format = "md_document")
```

This command will generate 5 md documents - one for each experiment - inside the directory [Reports](https://github.com/microbiome/benchmarking/tree/RiboRings/reports).

If you want to benchmark only some of the experiments, do:

```
# load data sets and store them into the list "containers"
# prepare a list of data frames "df" for the data on execution times
source("experiments/data.R", local = knitr::knit_global())

# load functions to run experiments and plot results
source("experiments/experiment.R", local = knitr::knit_global())

# render output of "EXPERIMENT_NAME" as an md document
rmarkdown::render("experiments/EXPERIMENT_NAME", output_format = "md_document", output_dir = "reports")
```

where `EXPERIMENT_NAME` can be:

* melt_benchmark.R;
* transform_benchmark.R;
* agglomerate_benchmark.R;
* alpha_benchmark.R;
* beta_benchmark.R.

To change the analysed data sets or the subsetting sizes, go to [data.R](https://github.com/microbiome/benchmarking/blob/RiboRings/experiments/data.R) and modify line 20 and line 23, respectively.

Right now, those lines should look like this:

```
# list data sets to run benchmark on
data_sets <- c("AsnicarF_2017", "GlobalPatterns")
```

```
# list sample sizes for random subsetting
sample_sizes <- c(10, 100)
```

To plot the execution times of a specific taxonomic rank and / or sample size, go to one of the [analytical routines](https://github.com/microbiome/benchmarking/tree/RiboRings/experiments) and modify the first 3 lines.

Right now, those lines should look like this:

```
# define sample size N and rank R for the plots
N <- 10
R <- "Order"
```

## License

The code and results in this repository are open source with [Artistic License 2.0](LICENSE.md).






