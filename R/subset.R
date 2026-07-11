# Import libraries
if (!require("BiocManager")) {
    install.packages("BiocManager")
    library("BiocManager")
}

pkgs <- c("mia", "phyloseq", "TreeSummarizedExperiment")

temp <- sapply(pkgs, function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        install(pkg)
        library(pkg, character.only = TRUE)
    }
})

# Import dataset
scratch_dir <- "/scratch/project_2014893/"
file_name <- paste0(scratch_dir, "metalog_tse.Rds")
x <- readRDS(file_name)

grid_df <- expand.grid(
    rows = 10^(1:4),
    cols = 10^(1:5),
    seed = seq(0, 9),
    sparsity = NA
)

stypes <- levels(colData(x)$collection)

for( stype in stypes ){
    grid_df[stype] <- NA
}

out_dir <- paste0(scratch_dir, "objects/")

for( i in seq_len(nrow(grid_df)) ){
    # Retrieve step params
    row.size <- grid_df[i, "rows"]
    col.size <- grid_df[i, "cols"]
    rand.state <- grid_df[i , "seed"]
    # Set output name
    out_name <- paste(
        format(row.size, scientific = FALSE),
        format(col.size, scientific = FALSE),
        rand.state,
        sep = "_"
    )
    # Set seed
    set.seed(rand.state)
    # Select a random subset of features
    tse <- x[sample(nrow(x), row.size), ]
    # Remove samples with only zeros
    tse <- tse[ , colSums(assay(tse)) != 0L]
    # Select a random subset of samples
    tse <- tse[ , sample(ncol(tse), col.size, replace = TRUE)]
    # Make sample names unique for repeated samples
    colnames(tse) <- make.unique(colnames(tse))
    # Prune tree to match subset
    tse <- TreeSummarizedExperiment::subsetByLeaf(tse, rowLeaf = rownames(tse))
    # Count rows with only zeros
    zero_rows <- sum(apply(assay(tse), 1L, function(row) all(row == 0L)))
    # Compute assay sparsity
    grid_df$sparsity[i] <- sum(assay(tse) == 0L) / prod(dim(tse))
    # Compute sample type proportions
    stable <- table(colData(tse)$collection)
    tabsum <- sum(stable)
    for( stype in stypes ){
        grid_df[i, stype] <- stable[[stype]] / tabsum
    }
    # Recalculate relative abundance
    assay(tse) <- apply(assay(tse), 2L, function(x) x / sum(x))
    # Find the minimum non-zero value
    pseudocount <- min(assay(tse)[assay(tse) != 0]) / 2
    # Add pseudocount
    assay(tse) <- assay(tse) + pseudocount
    
    tse_file <- paste0(out_dir, "tse/", out_name, ".rda")
    
    if( !file.exists(tse_file) ){
        
        saveRDS(tse, tse_file)
        
    }
    
    pseq_file <- paste0(out_dir, "pseq/", out_name, ".rda")
    
    if( !file.exists(pseq_file) ){
        # Convert TreeSE to phyloseq
        pseq <- mia::convertToPhyloseq(tse)
        # Export object
        saveRDS(pseq, pseq_file)
    }
    
    qiime_dir <- paste0(out_dir, "qiime/", out_name) 
    
    if( !dir.exists(qiime_dir) ){
        
        mia::exportQIIME2(tse, qiime_dir, group.var = "Family")
    
    }
}

# Save subset metadata
write.table(grid_df, "inst/extdata/metadata.tsv", row.names = FALSE)
