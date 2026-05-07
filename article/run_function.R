
# Add path to custom libraries (only for CSC)
.libPaths(c("/projappl/project_2014893/project_rpackages_451", .libPaths()))

# Import libraries
if (!require("BiocManager")) {
    install("BiocManager")
    library("BiocManager")
}

pkgs <- c("bench", "mia", "microbiome", "phyloseq", "picante", "philr", "speedyseq")

temp <- sapply(pkgs, function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        install(pkg)
        library(pkg, character.only = TRUE)
    }
})

# Set benchmarking hyperparameters
params <- commandArgs(trailingOnly = TRUE)
obj.type <- as.character(params[1])
obj.fun <- as.character(params[2])
bench.var <- as.character(params[3])
row.size <- as.integer(params[4])
col.size <- as.integer(params[5])
rand.state <- as.integer(params[6])

key <- paste0(obj.type, "_", obj.fun)

# Define expression to run
bench_expr <- switch(
    key,
    # Estimate faith from TreeSE
    tse_alpha = quote(mia::getAlpha(x, index = "faith_diversity")),
    # Estimate unifrac from TreeSE
    tse_beta = quote(mia::getDissimilarity(x, method = "unifrac")),
    # philr transform TreeSE
    tse_trans = quote(mia::transformAssay(x, method = "philr", MARGIN = 1L)),
    # Melt TreeSE
    tse_melt = quote(mia::meltSE(x, add.row = TRUE, add.col = TRUE)),
    # Agglomerate TreeSE
    tse_agg = quote(mia::agglomerateByRank(x, rank = "Family")),
    # Estimate faith from phyloseq
    pseq_alpha = quote(picante::pd(samp = t(otu_table(x)), tree = phy_tree(x))[, 1]),
    # Estimate unifrac from phyloseq
    pseq_beta = quote(phyloseq::UniFrac(x)),
    # philr transform phyloseq
    pseq_trans = quote(philr::philr(t(otu_table(x)), tree = phy_tree(x))),
    # Melt phyloseq
    pseq_melt = quote(phyloseq::psmelt(x)),
    # Agglomerate phyloseq
    pseq_agg = quote(phyloseq::tax_glom(x, taxrank = "Family")),
    # Melt speedyseq
    spseq_melt = quote(speedyseq::psmelt(x)),
    # Agglomerate speedyseq
    spseq_agg = quote(speedyseq::tax_glom(x, taxrank = "Family"))
)

scratch_dir <- "/scratch/project_2014893/"
data_dir <- paste0(scratch_dir, "objects/")
file_name <- paste(row.size, col.size, rand.state, sep = "_")

obj_dir <- ifelse(obj.type == "spseq", "pseq", obj.type)
file_path <- paste0(data_dir, obj_dir, "/", file_name)

# Import dataset
x <- readRDS(file_path)

# Build function call
bench_fun <- eval(parse(text = paste0("bench_", bench.var)))
# Run benchmark
out <- bench_fun(eval(bench_expr))

bench_col <- switch(bench.var, time = "real", memory = "mem_alloc")

out <- out[[bench_col]]

# Retrieve benchmarking results for each experiment and iteration
df <- data.frame(
    object = obj.type, method = obj.fun,
    var = bench.var, value = as.numeric(out),
    rows = row.size, cols = col.size, state = rand.state,
    row.names = NULL
)

file_name <- paste(
    obj.type, obj.fun, bench.var, row.size, col.size, rand.state, sep = "_"
)

write.table(
    df, file = paste0("out/", file_name, ".tsv"), sep = "\t", row.names = FALSE
)
