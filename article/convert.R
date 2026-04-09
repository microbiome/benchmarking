
# Add path to custom libraries (only for CSC)
.libPaths(c("/projappl/project_2014893/project_rpackages_451", .libPaths()))

library(mia)
library(phyloseq)
library(biomformat)

scratch_dir <- "/scratch/project_2014893/"

tse <- readRDS(paste0(scratch_dir, "metalog_tse.Rds"))

pseq <- convertToPhyloseq(tse)
saveRDS(pseq, paste0(scratch_dir, "metalog_pseq.Rds"))

biom <- convertToBIOM(tse)
write_biom(biom, paste0(scratch_dir, "metalog.biom"))


