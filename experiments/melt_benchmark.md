    ggplot(df, aes(x = Features, y = Melt, color = MeltCommand, shape = as.factor(Samples))) +
      geom_point() +
      labs(title = "Melting comparison",
           x = "Number of features",
           y = "Execution time in s",
           color = "method:", shape = "number of samples:",
           caption = "Execution time of melting as a function of number of features") +
      theme(legend.position = "bottom")

![](benchmark_files/figure-markdown_strict/melting_features-1.png)
