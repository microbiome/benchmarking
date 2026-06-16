
# Import libraries
# if (!require("BiocManager")) {
#     install.packages("BiocManager")
#     library("BiocManager")
# }

pkgs <- c("bench", "mia", "microbiome", "phyloseq", "picante", "philr", "speedyseq")

temp <- sapply(pkgs, function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        # install(pkg)
        library(pkg, character.only = TRUE)
    }
})


# Store main working directory
main_wd <- getwd()

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
    # Estimate faith with mia
    tse_alpha = quote(mia::getAlpha(x, index = "faith_diversity")),
    # Estimate unifrac with mia
    tse_beta = quote(mia::getDissimilarity(x, method = "unifrac")),
    # philr transform with mia
    tse_trans = quote(mia::transformAssay(x, method = "philr", MARGIN = 1L)),
    # Melt TreeSE
    tse_melt = quote(mia::meltSE(x, add.row = TRUE, add.col = TRUE)),
    # Agglomerate assay with mia
    tse_agg = quote(mia::agglomerateByRank(x, rank = "Family")),
    # Estimate faith with phyloseq
    pseq_alpha = quote(picante::pd(samp = t(otu_table(x)), tree = phy_tree(x))[, 1]),
    # Estimate unifrac with phyloseq
    pseq_beta = quote(phyloseq::UniFrac(x)),
    # philr transform with phyloseq
    pseq_trans = quote(philr::philr(t(otu_table(x)), tree = phy_tree(x))),
    # Melt phyloseq
    pseq_melt = quote(phyloseq::psmelt(x)),
    # Agglomerate assay with phyloseq
    pseq_agg = quote(phyloseq::tax_glom(x, taxrank = "Family")),
    # Melt speedyseq
    spseq_melt = quote(speedyseq::psmelt(x)),
    # Agglomerate assay with speedyseq
    spseq_agg = quote(speedyseq::tax_glom(x, taxrank = "Family")),
    # Estimate faith with mothur
    mothur_alpha = "#phylo.diversity(tree=tree.nwk, count=counts.tsv)",
    # Estimate unifrac with mothur
    mothur_beta = "#unifrac.unweighted(tree=tree.nwk, count=counts.tsv, distance=lt)",
    # Agglomerate with mothur
    mothur_agg = "#summary.tax(taxonomy=taxonomy.tsv, count=counts.tsv, groups=Family.group)",
    # Estimate faith with qiime
    qiime_alpha = paste("
        qiime diversity-lib faith-pd",
            "--i-table counts.qza",
            "--i-phylogeny tree.qza",
            "--o-vector faith-pd-vector.qza
    "),
    # Estimate unifrac from qiime
    qiime_beta = paste("
        qiime diversity-lib unweighted-unifrac",
            "--i-table counts.qza",
            "--i-phylogeny tree.qza",
            "--o-distance-matrix unweighted-unifrac-dm.qza
    "),
    # Agglomerate qiime
    qiime_agg = paste("
        qiime feature-table group",
            "--i-table counts.qza",
            "--m-metadata-file Family.tsv",
            "--m-metadata-column Family",
            "--p-mode sum",
            "--p-axis feature",
            "--o-grouped-table agg_table.qza
    ")
)

scratch_dir <- "/scratch/project_2014893/"
data_dir <- paste0(scratch_dir, "objects/")

obj_dir <- ifelse(obj.type == "spseq", "pseq", obj.type)
obj_file <- paste(row.size, col.size, rand.state, sep = "_")
obj_path <- paste0(data_dir, obj_dir, "/", obj_file)

if( obj.type %in% c("tse", "pseq", "spseq") ){
    
    # Import dataset
    x <- readRDS(paste0(obj_path, ".rda"))
    
}else{
    
    setwd(obj_path)
    
    if( obj.type == "mothur" ){

        bench_expr <- paste("mothur", shQuote(bench_expr))
        
    }
    
    bench_expr <- call("system", bench_expr)
}


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

setwd(main_wd)

file_name <- paste(
    obj.type, obj.fun, bench.var, row.size, col.size, rand.state, sep = "_"
)

write.table(
    df, file = paste0("out/", file_name, ".tsv"), sep = "\t", row.names = FALSE
)
