#!/bin/bash
#SBATCH --job-name=marmoset_robustness_cohort
#SBATCH --output=log/marmoset_robustness_cohort.%j.out
#SBATCH --error=log/marmoset_robustness_cohort.%j.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --exclude=n15,n01

scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); corr_all; exit"
