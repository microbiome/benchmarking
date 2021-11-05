# test melting for tse
melt_tse_exec_time <- function(tse) {
  
  start.time1 <- Sys.time()
  molten_tse <- mia::meltAssay(tse,
                               add_row_data = TRUE,
                               add_col_data = TRUE)
  end.time1 <- Sys.time()
  
  return(end.time1 - start.time1)
  
}

# test melting for pseq
melt_pseq_exec_time <- function(pseq) {
  
  start.time2 <- Sys.time()
  molten_pseq <- phyloseq::psmelt(pseq)
  end.time2 <- Sys.time()
  
  return(end.time2 - start.time2)
  
}
