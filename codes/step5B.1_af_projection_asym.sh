#!/bin/bash
#SBATCH --job-name=af_projection_asym
#SBATCH --output=log/af_projection_asym.%j.out
#SBATCH --error=log/af_projection_asym.%j.out
#SBATCH --partition=cpu


matlab -nodisplay -nosplash -r "asym_projection; exit"
