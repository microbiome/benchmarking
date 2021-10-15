    ggplot(df, aes(x = Features, y = Agglomerate, color = AgglomerateCommand, shape = as.factor(Samples))) +
      geom_point() +
      labs(title = "Agglomeration comparison",
           x = "Number of features",
           y = "Execution time in s",
           color = "method:",
           shape = "number of samples:",
           caption = "Execution time of agglomeration as a function of number of features") +
      theme(legend.position = "bottom")

![](benchmark_files/figure-markdown_strict/agglomeration_features-1.png)
