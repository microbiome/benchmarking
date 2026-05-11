#!/bin/bash

# Loop through all subdirectories in the current directory
for SUBDIR in */; do
    
    # Change to the subdirectory
    cd $SUBDIR || exit
    
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
        --type 'FeatureData[Taxonomy]' \
        --output-path taxonomy.qza
    
    # Import phylogenetic tree
    qiime tools import \
        --input-path tree.nwk \
        --type 'Phylogeny[Rooted]' \
        --output-path tree.qza
    
    # Move back to the parent directory
    cd ..
    
done
