# -------------------------------
# OLD, remove?

# render output as a md document
# rmarkdown::render("experiments/transform_benchmark.R", output_format = "md_document", output_file = "transform_benchmark.md", output_dir = "reports")

# render output as a md document
# rmarkdown::render("experiments/agglomerate_benchmark.R", output_format = "md_document", output_file = "agglomerate_benchmark.md", output_dir = "reports")

# render output as a md document
# rmarkdown::render("experiments/alpha_benchmark.R", output_format = "md_document", output_file = "alpha_benchmark.md", output_dir = "reports")

# render output as a md document
# rmarkdown::render("experiments/beta_benchmark.R", output_format = "md_document", output_file = "beta_benchmark.md", output_dir = "reports")
If you want to benchmark only some of the experiments, do:

```
# load data sets and store them into the list "containers"
# prepare a list of data frames "df" for the data on execution times
source("experiments/data.R")

# load functions to run experiments and plot results
source("experiments/experiment.R")

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

You can also customise the threshold for the minimum number of features in line 38:

```
# define minimal number of features an altExp should contain
min_features <- 10
```

To plot the execution times of a specific taxonomic rank and / or sample size, go to one of the [analytical routines](https://github.com/microbiome/benchmarking/tree/RiboRings/experiments) and modify the lines 11 and 12.

Right now, those lines should look like this:

```
# define sample size N and rank R for the plots
N <- 10
R <- "Order"
```
