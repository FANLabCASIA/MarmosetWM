#!/bin/bash
#SBATCH --job-name=marmoset_robustness_cohort_fiber
#SBATCH --output=log/marmoset_robustness_cohort_fiber.%A_%a.out
#SBATCH --error=log/marmoset_robustness_cohort_fiber.%A_%a.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --exclude=n15,n01,n06
#SBATCH --array=1-45

scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); corr_f($SLURM_ARRAY_TASK_ID); exit"
