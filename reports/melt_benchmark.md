    source("melt_benchmark.R", local = knitr::knit_global())

    # run benchmark on melting of tse and pseq with custom sample sizes
    df_melt <- experiment_benchmark(containers, df, melt_tse_exec_time, melt_pseq_exec_time, sample_sizes)

    # merge results from each data set into one data frame
    df_melt <- merge_all(df_melt)

    # plot execution time for melting subsets from
    # the taxonomic rank "Order" and with 100 samples 
    p1_melt <- plot_exec_time(df_melt, 100, "Order")
    p1_melt

![](benchmark_files/figure-markdown_strict/melt_ex_time.png)

    # plot execution time ratio for melting subsets from
    # the taxonomic rank "Order" and with 1000 samples
    p2_melt <- plot_ratio(df_melt, 1000, "Order")
    p2_melt

![](benchmark_files/figure-markdown_strict/melt_ratio.png)
