# Import libraries
if (!require("BiocManager")) {
    install.packages("BiocManager")
    library("BiocManager")
}

pkgs <- c("mia")

temp <- sapply(pkgs, function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        install(pkg)
        library(pkg, character.only = TRUE)
    }
})

scratch_dir <- "/scratch/project_2014893/"

tse <- readRDS(paste0(scratch_dir, "orig_metalog_tse.Rds"))

assayNames(tse) <- "counts"

tse <- agglomerateByRank(tse, rank = "Genus")

saveRDS(tse, paste0(scratch_dir, "metalog_tse.Rds"))

