    ggplot(df, aes(x = Features, y = AlphaEstimation, color = AlphaCommand, shape = as.factor(Samples))) +
      geom_point() +
      labs(title = "Alpha Diversity Estimation comparison",
           x = "Number of features",
           y = "Execution time in s",
           color = "method:",
           shape = "number of samples:",
           caption = "Execution time of estimating alpha diversity as a function of number of features") +
      theme(legend.position = "bottom")

![](benchmark_files/figure-markdown_strict/alpha_features-1.png)