#!/bin/bash
#SBATCH --job-name=reg
#SBATCH --output=log/reg.%j.out
#SBATCH --error=log/reg.%j.out
#SBATCH --partition=cpu
#SBATCH --nodes=1

matlab -nodisplay -nosplash -r "addpath(genpath('/n05dat/yfwang/user/MarmosetWM/script/util')); calc_overlap; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('/n05dat/yfwang/user/MarmosetWM/script/util')); calc_dice_extension; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('/n05dat/yfwang/user/MarmosetWM/script/util')); calc_localcorr; exit"
