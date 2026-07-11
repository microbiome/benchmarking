#!/bin/bash -l
#SBATCH --job-name=preprocess
#SBATCH --account=project_2014893
#SBATCH --output=./logs/out/output_%j.txt
#SBATCH --error=./logs/errors/errors_%j.txt
#SBATCH --partition=small
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=0
#SBATCH --mail-type=END

# Activate container
module load tykky
tykky activate miabench/miabench_env

# Clean up .Renviron file in home directory
if test -f ~/.Renviron; then
	sed -i '/TMPDIR/d' ~/.Renviron
fi

# Specify a temp folder path
echo "TMPDIR=/scratch/project_2014893" >> ~/.Renviron

# Change working directory
cd benchmarking/R

# Preprocess original object
# 128 GB of memory is needed
Rscript convert.R

# Create experiment subsets
Rscript subset.R

# Create tasks file
Rscript tasks.R

# Change working directory
cd /scratch/project_2014893/objects/qiime

# Preprocess qiime files
# 256 GB of memory is needed
bash /projappl/project_2014893/benedett/benchmarking/qiime_preprocess.sh
