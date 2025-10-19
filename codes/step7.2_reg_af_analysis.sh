#!/bin/bash
#SBATCH --job-name=reg
#SBATCH --output=log/reg.%j.out
#SBATCH --error=log/reg.%j.out
#SBATCH --partition=cpu
#SBATCH --nodes=1

scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script

matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); calc_overlap; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); calc_dice_extension; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); calc_localcorr_group; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); calc_localcorr; exit"
