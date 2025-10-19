#!/bin/bash
#SBATCH --job-name=divergence_group
#SBATCH --output=log/divergence_group.%j.out
#SBATCH --error=log/divergence_group.%j.out
#SBATCH --partition=cpu

scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script

matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); bp_xspecies_group; exit"
