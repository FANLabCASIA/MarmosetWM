#!/bin/bash
#SBATCH --job-name=run
#SBATCH --output=log/run.%j.out
#SBATCH --error=log/run.%j.out
#SBATCH --partition=cpu
#SBATCH --nodes=1

matlab -nodisplay -nosplash -r "volume_af_projection_human; exit"
matlab -nodisplay -nosplash -r "volume_af_projection_chimp; exit"
matlab -nodisplay -nosplash -r "volume_af_projection_macaque_tvb; exit"
matlab -nodisplay -nosplash -r "volume_af_projection_macaque_ucd; exit"
matlab -nodisplay -nosplash -r "volume_af_projection_marmoset_MBM; exit"
matlab -nodisplay -nosplash -r "volume_af_projection_marmoset_minds; exit"
