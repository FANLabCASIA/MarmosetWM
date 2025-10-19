#!/bin/bash
#SBATCH --job-name=divergence_dataset
#SBATCH --output=log/divergence_dataset.%j.out
#SBATCH --error=log/divergence_dataset.%j.out
#SBATCH --partition=cpu

scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script

matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); indi_bp_atlas_macaque_ucd; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); indi_bp_atlas_marmoset_brain_minds; exit"

matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); bp_xspecies_ind_mac2h_ucd; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); bp_xspecies_ind_mar2h_brain_minds; exit"
