#!/bin/bash
#SBATCH --job-name=marmoset_KL
#SBATCH --output=log/marmoset_KL.%j.out
#SBATCH --error=log/marmoset_KL.%j.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --exclude=n05,n15

matlab -nodisplay -nosplash -r "addpath(genpath('/n02dat01/users/yfwang/MarmosetWM/script/util')); bp_knockout; exit"
