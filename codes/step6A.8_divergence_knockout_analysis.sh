#!/bin/bash
#SBATCH --job-name=divergence_knockout
#SBATCH --output=log/divergence_knockout.%j.out
#SBATCH --error=log/divergence_knockout.%j.out
#SBATCH --partition=cpu

scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script

matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); bp_knockout_ind_c2h; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); bp_knockout_ind_mac2h; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); bp_knockout_ind_mar2h; exit"
