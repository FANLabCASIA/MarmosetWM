#!/bin/bash
#SBATCH --job-name=KL
#SBATCH --output=log/KL.%j.out
#SBATCH --error=log/KL.%j.out
#SBATCH --partition=cpu

matlab -nodisplay -nosplash -r "addpath(genpath('/n05dat/yfwang/user/MarmosetWM/script/util')); bp_xspecies_minds; exit"
