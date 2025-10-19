#!/bin/bash
#SBATCH --job-name=af_projection
#SBATCH --output=log/af_projection.%j.out
#SBATCH --error=log/af_projection.%j.out
#SBATCH --partition=cpu

matlab -nodisplay -nosplash -r "af_projection_human_ifod2; exit"
matlab -nodisplay -nosplash -r "af_projection_chimp_ifod2; exit"
matlab -nodisplay -nosplash -r "af_projection_macaque_tvb_ifod2; exit"
matlab -nodisplay -nosplash -r "af_projection_marmoset_MBM_ifod2; exit"
