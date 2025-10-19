#!/bin/bash
#SBATCH --job-name=af_volume_asym
#SBATCH --output=log/af_volume_asym.%j.out
#SBATCH --error=log/af_volume_asym.%j.out
#SBATCH --partition=cpu


matlab -nodisplay -nosplash -r "asym_volume; exit"
