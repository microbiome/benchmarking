obj.types <- c("tse", "pseq", "spseq", "qiime")
obj.funs <- c("alpha", "beta", "trans", "agg", "melt")
row.sizes <- 10^(1:4)
col.sizes <- 10^(1:5)
rand.state <- 1

df <- expand.grid(
    object = obj.types,
    method = obj.funs,
    rows = row.sizes,
    cols = col.sizes
)

to_remove <- (df$object == "spseq" & df$method %in% c("alpha", "beta", "trans")) |
    (df$object == "qiime" & df$method %in% c("trans", "melt"))

df <- df[!to_remove, ]

df <- df[order(df$object, df$method, df$rows, 1 / df$cols), ]

df$rows <- format(df$rows, scientific = FALSE, trim = TRUE)
df$cols <- format(df$cols, scientific = FALSE, trim = TRUE)

prior.out <- list.files("out/time/", recursive = TRUE)
prior.out <- gsub("^[0-9]/(.*)\\.tsv$", "\\1", prior.out)
prior.out <- gsub("/", "_", prior.out, fixed = TRUE)

times <- apply(df, 1L, paste, collapse = "_")
times <- times[!times %in% prior.out]

times <- gsub("_", " ", times, fixed = TRUE)
times <- paste("run_function.R", times, "time", rand.state)

writeLines(times, "times.txt")

mems <- gsub("_", " ", prior.out, fixed = TRUE)
mems <- paste("run_function.R", mems, "memory", rand.state)

writeLines(mems, "mems.txt")
