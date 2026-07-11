#!/bin/bash -l
#SBATCH --job-name=array
#SBATCH --account=project_2014893
#SBATCH --output=./logs/out/output_%A_%a.txt
#SBATCH --error=./logs/errors/errors_%A_%a.txt
#SBATCH --partition=small
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4g
#SBATCH --array=1-300%20
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

# Change to "mems.txt" when benchmarking memory
task=$(sed -n "${SLURM_ARRAY_TASK_ID}p" times.txt)

echo "$task"

# Run the R script
bash -c "Rscript $task"
