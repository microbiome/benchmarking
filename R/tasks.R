obj.types <- c("tse", "pseq", "spseq", "qiime")
obj.funs <- c("alpha", "beta", "trans", "agg", "melt")
bench.vars <- c("time")#, "memory")
row.sizes <- 10^(1:4)
col.sizes <- 10^(1:5)
rand.states <- 1

df <- expand.grid(
    object = obj.types,
    method = obj.funs,
    var = bench.vars,
    rows = row.sizes,
    cols = col.sizes,
    seed = rand.states
)

to_remove <- (df$object == "spseq" & df$method %in% c("alpha", "beta", "trans")) |
    (df$object == "qiime" & df$method %in% c("trans", "melt"))

df <- df[!to_remove, ]

df <- df[order(df$object, df$method, df$rows, 1 / df$cols), ]

df$rows <- format(df$rows, scientific = FALSE, trim = TRUE)
df$cols <- format(df$cols, scientific = FALSE, trim = TRUE)

prior.out <- gsub(".tsv", "", list.files("out"), fixed = TRUE)

lines <- apply(df, 1L, paste, collapse = "_")

lines <- lines[!lines %in% prior.out]

lines <- gsub("_", " ", lines, fixed = TRUE)

lines <- paste("run_function.R", lines)

writeLines(lines, "tasks.txt")
