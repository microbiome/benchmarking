    ggplot(df, aes(x = Features, y = BetaEstimation, color = BetaCommand, shape = as.factor(Samples))) +
      geom_point() +
      labs(title = "Beta Diversity Estimation comparison",
           x = "Number of features",
           y = "Execution time in s",
           color = "method:",
           shape = "number of samples:",
           caption = "Execution time of estimating beta diversity as a function of number of features") +
      theme(legend.position = "bottom")

![](benchmark_files/figure-markdown_strict/beta_features-1.png)
