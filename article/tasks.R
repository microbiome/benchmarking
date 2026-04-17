
obj.types <- c("tse", "pseq", "spseq")#, "qiime", "mothur")
obj.funs <- c("alpha", "beta", "trans", "agg", "melt")
row.sizes <- 10^(1:4)
col.sizes <- 10^(1:5)
rand.states <- 0

df <- expand.grid(
    command = "run_function.R",
    object = obj.types,
    method = obj.funs,
    rows = row.sizes,
    cols = col.sizes,
    seed = rand.states
)

to_remove <- (df$object == "spseq" & df$method %in% c("alpha", "beta", "trans")) |
    (df$object %in% c("qiime", "mothur") & df$method %in% c("trans", "melt"))

df <- df[!to_remove, ]

df <- df[order(df$cols * df$rows, df$method, df$object), ]

df$rows <- format(df$rows, scientific = FALSE, trim = TRUE)
df$cols <- format(df$cols, scientific = FALSE, trim = TRUE)

lines <- apply(df, 1L, paste, collapse = " ")
writeLines(lines, "tasks.txt")
