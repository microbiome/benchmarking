#!/bin/bash

# Loop through all subdirectories in the current directory
for SUBDIR in */; do

    # Change to the subdirectory
    cd "$SUBDIR" || exit
    
    # Delete prior results
    rm -f "faith-pd-vector.qza" "unweighted-unifrac-dm.qza" "agg_table.qza"

    # Convert classic BIOM table to HDF5
    if [ ! -f "counts.hdf5" ]; then
        biom convert -i counts.tsv -o counts.hdf5 --to-hdf5
    fi

    # Import counts
    if [ ! -f "counts.qza" ]; then
        qiime tools import \
            --input-path counts.hdf5 \
            --type 'FeatureTable[Frequency]' \
            --input-format BIOMV210Format \
            --output-path counts.qza
    fi

    # Import taxonomy
    if [ ! -f "taxonomy.qza" ]; then
        qiime tools import \
            --input-path taxonomy.tsv \
            --type 'FeatureData[Taxonomy]' \
            --output-path taxonomy.qza
    fi

    # Import phylogenetic tree
    if [ ! -f "tree.qza" ]; then
        qiime tools import \
            --input-path tree.nwk \
            --type 'Phylogeny[Rooted]' \
            --output-path tree.qza
    fi

    # Move back to the parent directory
    cd ..
done

