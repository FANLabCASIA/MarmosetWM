#!/bin/bash
#SBATCH --job-name=divergence_indi
#SBATCH --output=log/divergence_indi.%j.out
#SBATCH --error=log/divergence_indi.%j.out
#SBATCH --partition=cpu

scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script

matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); indi_bp_atlas_human; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); indi_bp_atlas_chimp; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); indi_bp_atlas_macaque_tvb; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); indi_bp_atlas_marmoset_MBM; exit"

matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); bp_xspecies_ind_c2h; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); bp_xspecies_ind_mac2h; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); bp_xspecies_ind_mar2h; exit"
