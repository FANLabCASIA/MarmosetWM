#!/bin/bash
#SBATCH --job-name=marmoset_robustness_cohort
#SBATCH --output=log/marmoset_robustness_cohort.%j.out
#SBATCH --error=log/marmoset_robustness_cohort.%j.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --exclude=n15,n01

matlab -nodisplay -nosplash -r "addpath(genpath('/n02dat01/users/yfwang/MarmosetWM/script/util')); corr_all; exit"

