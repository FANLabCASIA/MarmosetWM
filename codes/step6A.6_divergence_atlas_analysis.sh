#!/bin/bash
#SBATCH --job-name=divergence_atlas
#SBATCH --output=log/divergence_atlas.%j.out
#SBATCH --error=log/divergence_atlas.%j.out
#SBATCH --partition=cpu

scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script

matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); indi_bp_atlas_marmoset_Paxinos; exit"

matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); bp_xspecies_ind_mar2h_Paxinos; exit"
