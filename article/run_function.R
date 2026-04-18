
# Add path to custom libraries (only for CSC)
.libPaths(c("/projappl/project_2014893/project_rpackages_451", .libPaths()))

# Import libraries
if (!require("BiocManager")) {
    install("BiocManager")
    library("BiocManager")
}

pkgs <- c("bench", "mia", "microbiome", "phyloseq", "picante", "philr",
          "speedyseq", "tidyverse")

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
row.size <- as.integer(params[3])
col.size <- as.integer(params[4])
rand.state <- as.integer(params[5])

key <- paste0(obj.type, "_", obj.fun)

# Define expression to run
expr <- switch(
    key,
    # Estimate faith from TreeSE
    tse_alpha = quote(mia::getAlpha(tse, index = "faith_diversity")),
    # Estimate unifrac from TreeSE
    tse_beta = quote(mia::getDissimilarity(tse, method = "unifrac")),
    # philr transform TreeSE
    tse_trans = quote(mia::transformAssay(tse, method = "philr", MARGIN = 1L, pseudocount = 1)),
    # Melt TreeSE
    tse_melt = quote(mia::meltSE(tse, add.row = TRUE, add.col = TRUE)),
    # Agglomerate TreeSE
    tse_agg = quote(mia::agglomerateByRank(tse, rank = "Family")),
    # Estimate faith from phyloseq
    pseq_alpha = quote(picante::pd(samp = t(otu_table(pseq)), tree = phy_tree(pseq))[, 1]),
    # Estimate unifrac from phyloseq
    pseq_beta = quote(phyloseq::UniFrac(pseq)),
    # philr transform phyloseq
    pseq_trans = quote(philr::philr(t(otu_table(pseq)), tree = phy_tree(pseq), pseudocount = 1)),
    # Melt phyloseq
    pseq_melt = quote(phyloseq::psmelt(pseq)),
    # Agglomerate phyloseq
    pseq_agg = quote(phyloseq::tax_glom(pseq, taxrank = "Family")),
    # Melt speedyseq
    spseq_melt = quote(speedyseq::psmelt(pseq)),
    # Agglomerate speedyseq
    spseq_agg = quote(speedyseq::tax_glom(pseq, taxrank = "Family")),
    qiime_alpha = "
        qiime diversity-lib faith-pd \
            --i-table feature-table.qza \
            --i-phylogeny phylogeny.qza \
            --o-vector faith-pd-vector.qza
    ",
    qiime_beta = "
        qiime diversity-lib unweighted-unifrac \
            --i-table feature-table.qza \
            --i-phylogeny phylogeny.qza \
            --o-distance-matrix unweighted-unifrac-dm.qza
    ",
    qiime_agg = "
        qiime feature-table group \
            --i-table feature-table.qza \
            --m-metadata-file sample-metadata.tsv \
            --m-metadata-column family-rank \
            --p-mode sum \
            --p-axis feature \
            --o-grouped-table agg_table.qza
    ",
    mothur_alpha = "phylo.diversity(tree=tree.nwk, count=counts.tsv, rarefy=F)",
    mothur_beta = "unifrac.unweighted(tree=tree.nwk, count=counts.tsv, distance=lt, random=F, subsample=F)",
    mothur_agg = "summary.tax(taxonomy=taxonomy.tsv, count=counts.tsv, group=rank.groups)" # maybe
)

# Import dataset
scratch_dir <- "/scratch/project_2014893/"
file_name <- paste0(scratch_dir, "metalog_tse.Rds")
tse <- readRDS(file_name)

set.seed(rand.state)

# Select a random subset of features
tse <- tse[sample(nrow(tse), row.size), ]

# Remove samples with only zeros
tse <- tse[ , colSums(assay(tse)) != 0L]

# Select a random subset of samples
tse <- tse[ , sample(ncol(tse), col.size)]

# Recalculate relative abundance
assay(tse) <- apply(assay(tse), 2L, function(x) x / sum(x))

if( obj.type %in% c("pseq", "spseq") ){
    
    # Convert TreeSE to phyloseq
    pseq <- mia::convertToPhyloseq(tse)
    
}else if( obj.type == "qiime" ){
    
    biom <- as_rbiom(tse)
    rbiom::write_qiime2(biom, "unique_tmp_dir?", prefix = "")
    
    system("convert2qiime.sh")
    
    qiime_commands <- "
        # Convert classic BIOM table to HDF5
        biom convert -i counts.tsv -o counts.hdf5 --to-hdf5
        
        # Import counts
        qiime tools import \
            --input-path counts.hdf5 \
            --type 'FeatureTable[Frequency]' \
            --input-format BIOMV210Format \
            --output-path counts.qza
        
        # Import taxonomy
        qiime tools import \
            --input-path taxonomy.tsv \
            --type FeatureData[Taxonomy] \
            --output-path taxonomy.qza
        
        # Import phylogenetic tree
        qiime tools import \
            --input-path tree.nwk \
            --type 'Phylogeny[Rooted]' \
            --output-path tree.qza
    "
    
}else if( obj.type == "mothur" ){
    
    biom <- as_rbiom(tse)
    rbiom::write_mothur(biom, "unique_tmp_dir?", prefix = "")
    
    "make.shared(count=counts.tsv, label=asv)"
    
}

# Run benchmark
out <- bench::mark(
    exprs = list(expr),
    iterations = 1,
    memory = TRUE,
    check = FALSE
)

# Retrieve benchmarking results for each experiment and iteration
df <- out |>
    unnest(c(time, gc)) |>
    dplyr::transmute(
        object = obj.type, method = obj.fun,
        rows = row.size, cols = col.size, state = rand.state,
        time = as.numeric(time), memory = as.numeric(mem_alloc), gc
    )

file_name <- paste(obj.type, obj.fun, row.size, col.size, rand.state, sep = "_")

write.table(
    df, file = paste0("out/", file_name, ".tsv"), sep = "\t", row.names = FALSE
)
