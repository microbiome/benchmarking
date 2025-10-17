# run benchmark of tse and pseq with custom sample sizes
df_benchmark <- experiment_benchmark(containers,
                                     tests[[testmethod]], 
                                     sample_sizes)
