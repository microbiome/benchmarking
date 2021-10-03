Computational efficiency of TreeSE methods
==========================================

This document provides some benchmarking results comparing the
computational efficiency in standard operations between
`TreeSummarizedExperiment` (tse) and `phyloseq` (pseq) containers for
microbiome data.

Introduction
------------

To estimate the time efficiency of homologous tasks but with different
data structures (`tse` or `pseq`), we have benchmarked a set of standard
data manipulation routines on data sets of varying numbers of samples
and features, as reported below.

Data sets
---------

The comparisons are based on publicly available data sets from the
curatedMetagenomicData project. See the homepage for the details and
references.

    # Working variables are assigned with a placeholder to work with them inside the next for loop.
    data_sets <- c("AsnicarF_2017.relative_abundance", "GlobalPatterns", "SilvermanAGutData", "SongQAData", "SprockettTHData", "GrieneisenTSData")
    len_set <- length(data_sets)
    tse <- TreeSummarizedExperiment()
    tmp <- list()

    ## Warning in rm("object_types", "melt_command", "transform_command",
    ## "agglomerate_command", : object 'object_types' not found

    ## Warning in rm("object_types", "melt_command", "transform_command",
    ## "agglomerate_command", : object 'melt_command' not found

    ## Warning in rm("object_types", "melt_command", "transform_command",
    ## "agglomerate_command", : object 'transform_command' not found

    ## Warning in rm("object_types", "melt_command", "transform_command",
    ## "agglomerate_command", : object 'agglomerate_command' not found

    ## Warning in rm("object_types", "melt_command", "transform_command",
    ## "agglomerate_command", : object 'alpha_command' not found

    ## Warning in rm("object_types", "melt_command", "transform_command",
    ## "agglomerate_command", : object 'beta_command' not found

    ## Warning in rm("object_types", "melt_command", "transform_command",
    ## "agglomerate_command", : object 'assay_values' not found

Execution times for different experiments, data sets and containers are
evaluated with a recursive approach. Results are stored into `df`.

Compare execution times
=======================

    ## snapshotDate(): 2021-09-24

    ## 
    ## $`2021-03-31.AsnicarF_2017.relative_abundance`
    ## dropping rows without rowTree matches:
    ##   k__Bacteria|p__Actinobacteria|c__Coriobacteriia|o__Coriobacteriales|f__Coriobacteriaceae|g__Collinsella|s__Collinsella_stercoris
    ##   k__Bacteria|p__Actinobacteria|c__Coriobacteriia|o__Coriobacteriales|f__Coriobacteriaceae|g__Enorma|s__[Collinsella]_massiliensis
    ##   k__Bacteria|p__Firmicutes|c__Bacilli|o__Lactobacillales|f__Carnobacteriaceae|g__Granulicatella|s__Granulicatella_elegans
    ##   k__Bacteria|p__Firmicutes|c__Clostridia|o__Clostridiales|f__Ruminococcaceae|g__Ruminococcus|s__Ruminococcus_champanellensis
    ##   k__Bacteria|p__Proteobacteria|c__Betaproteobacteria|o__Burkholderiales|f__Sutterellaceae|g__Sutterella|s__Sutterella_parvirubra
    ##   k__Bacteria|p__Synergistetes|c__Synergistia|o__Synergistales|f__Synergistaceae|g__Cloacibacillus|s__Cloacibacillus_evryensis

    ## Warning in .get_x_with_pruned_tree(x): rowTree is pruned to match rownames.

    ## Warning in microbiome::transform(pseq, transform = "log10p", target = "sample"): log10p transformation is not typically 
    ##         used and not recommended for samples. Consider using target = OTU.

    ## Warning in microbiome::transform(pseq, transform = "log10p", target = "sample"): log10p transformation is not typically 
    ##         used and not recommended for samples. Consider using target = OTU.

    ## snapshotDate(): 2021-09-24

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## Warning: 'x' contains a column 'SampleID' in its colData(), which will be renamed to 'SampleID_col'

    ## Warning: log10p transformation is not typically 
    ##         used and not recommended for samples. Consider using target = OTU.

    ## snapshotDate(): 2021-09-24

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## Warning in microbiome::transform(pseq, transform = "log10p", target = "sample"): log10p transformation is not typically 
    ##         used and not recommended for samples. Consider using target = OTU.

    ## Warning in (function (x, method = "bray", binary = FALSE, diag = FALSE, : you
    ## have empty rows: their dissimilarities may be meaningless in method "bray"

    ## snapshotDate(): 2021-09-24

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## Warning in microbiome::transform(pseq, transform = "log10p", target = "sample"): log10p transformation is not typically 
    ##         used and not recommended for samples. Consider using target = OTU.

    ## snapshotDate(): 2021-09-24

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## see ?microbiomeDataSets and browseVignettes('microbiomeDataSets') for documentation

    ## loading from cache

    ## Warning in microbiome::transform(pseq, transform = "log10p", target = "sample"): log10p transformation is not typically 
    ##         used and not recommended for samples. Consider using target = OTU.

### Melting

Melting versus samples.

    ggplot(df, aes(x = Samples, y = Melt, color = MeltCommand, shape = as.factor(Features))) +
      geom_point() +
      labs(title = "Melting comparison", x = "Number of samples", y = "Execution time in s", color = "method:", shape = "number of features:", caption = "Execution time of melting as a function of number of samples") +
      theme_classic() +
      theme(legend.position = "bottom")

![](speed_comparisons_files/figure-markdown_strict/melting_samples-1.png)

Melting versus features.

    ggplot(df, aes(x = Features, y = Melt, color = MeltCommand, shape = as.factor(Samples))) +
      geom_point() +
      labs(title = "Melting comparison",
           x = "Number of features",
           y = "Execution time in s",
           color = "method:", shape = "number of samples:",
           caption = "Execution time of melting as a function of number of features") +
      theme_classic() +
      theme(legend.position = "bottom")

![](speed_comparisons_files/figure-markdown_strict/melting_features-1.png)

### Transformations

    ggplot(df, aes(x = Samples, y = Transform, color = TransformCommand, shape = as.factor(Features))) +
      geom_point() +
      labs(title = "Transformation comparison",
           x = "Number of samples",
           y = "Execution time in s",
           color = "method:",
           shape = "number of features:",
           caption = "Execution time of transformation as a function of number of samples") +
      theme(legend.position = "bottom")

![](speed_comparisons_files/figure-markdown_strict/transformation_samples-1.png)

    ggplot(df, aes(x = Features, y = Transform, color = TransformCommand, shape = as.factor(Samples))) +
      geom_point() +
      labs(title = "Transformation comparison",
           x = "Number of features",
           y = "Execution time in s",
           color = "method:", shape = "number of samples:",
           caption = "Execution time of transformation as a function of number of features") +
      theme(legend.position = "bottom")

![](speed_comparisons_files/figure-markdown_strict/transformation_features-1.png)

### Agglomeration

Agglomeration versus samples

    ggplot(df, aes(x = Samples, y = Agglomerate, color = AgglomerateCommand, shape = as.factor(Features))) +
      geom_point() +
      labs(title = "Agglomeration comparison",
           x = "Number of samples",
           y = "Execution time in s",
           color = "method:",
           shape = "number of features:",
           caption = "Execution time of agglomeration as a function of number of samples") +
      theme(legend.position = "bottom")

![](speed_comparisons_files/figure-markdown_strict/agglomeration_samples-1.png)

Agglomeration versus features

    ggplot(df, aes(x = Features, y = Agglomerate, color = AgglomerateCommand, shape = as.factor(Samples))) +
      geom_point() +
      labs(title = "Agglomeration comparison",
           x = "Number of features",
           y = "Execution time in s",
           color = "method:",
           shape = "number of samples:",
           caption = "Execution time of agglomeration as a function of number of features") +
      theme(legend.position = "bottom")

![](speed_comparisons_files/figure-markdown_strict/agglomeration_features-1.png)

### Alpha diversity

Beta diversity versus sample size.

    ggplot(df, aes(x = Samples, y = AlphaEstimation, color = AlphaCommand, shape = as.factor(Features))) +
      geom_point() +
      labs(title = "Alpha Diversity Estimation comparison",
           x = "Number of samples",
           y = "Execution time in s",
           color = "method:",
           shape = "number of features:",
           caption = "Execution time of estimating alpha diversity as a function of number of samples") +
      theme(legend.position = "bottom")

![](speed_comparisons_files/figure-markdown_strict/alpha_samples-1.png)

Beta diversity versus feature size.

    ggplot(df, aes(x = Features, y = AlphaEstimation, color = AlphaCommand, shape = as.factor(Samples))) +
      geom_point() +
      labs(title = "Alpha Diversity Estimation comparison",
           x = "Number of features",
           y = "Execution time in s",
           color = "method:",
           shape = "number of samples:",
           caption = "Execution time of estimating alpha diversity as a function of number of features") +
      theme(legend.position = "bottom")

![](speed_comparisons_files/figure-markdown_strict/alpha_features-1.png)

### Beta diversity

Beta diversity versus sample size.

    ggplot(df, aes(x = Samples, y = BetaEstimation, color = BetaCommand, shape = as.factor(Features))) +
      geom_point() +
      labs(title = "Beta Diversity Estimation comparison",
           x = "Number of samples",
           y = "Execution time in s",
           color = "method:",
           shape = "number of features:",
           caption = "Execution time of estimating beta diversity as a function of number of samples") +
      theme(legend.position = "bottom")

![](speed_comparisons_files/figure-markdown_strict/beta_samples-1.png)

Beta diversity versus feature size.

    ggplot(df, aes(x = Features, y = BetaEstimation, color = BetaCommand, shape = as.factor(Samples))) +
      geom_point() +
      labs(title = "Beta Diversity Estimation comparison",
           x = "Number of features",
           y = "Execution time in s",
           color = "method:",
           shape = "number of samples:",
           caption = "Execution time of estimating beta diversity as a function of number of features") +
      theme(legend.position = "bottom")

![](speed_comparisons_files/figure-markdown_strict/beta_features-1.png)

Mean difference in execution time
=================================

    mean_time <- df %>% group_by(ObjectType) %>%
                        summarize(mean_melt = mean(Melt),
                          mean_transform = mean(Transform),
                      mean_agglomerate = mean(Agglomerate),
                      mean_alpha = mean(AlphaEstimation),
                      mean_beta = mean(BetaEstimation, na.rm = TRUE))
    mean_time

    ## # A tibble: 2 × 6
    ##   ObjectType mean_melt mean_transform mean_agglomerate mean_alpha mean_beta
    ##   <chr>          <dbl>          <dbl>            <dbl>      <dbl>     <dbl>
    ## 1 pseq            7.03          0.195             2.75      0.112      8.87
    ## 2 tse             1.08          0.562             1.05      0.321      2.65
