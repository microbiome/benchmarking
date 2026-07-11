#!/bin/bash -l
#SBATCH --job-name=single
#SBATCH --account=project_2014893
#SBATCH --output=./logs/out/output_%j.txt
#SBATCH --error=./logs/errors/errors_%j.txt
#SBATCH --partition=test
#SBATCH --time=00:15:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
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

cd benchmarking/R

# Run single R script
Rscript run_function.R tse alpha 'time' 1000 1000 1
