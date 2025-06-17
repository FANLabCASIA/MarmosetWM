#!/bin/bash
#SBATCH --job-name=marmoset_surf_2_asc
#SBATCH --output=log/marmoset_surf_2_asc.%j.out
#SBATCH --error=log/marmoset_surf_2_asc.%j.out
#SBATCH --partition=cpu
#SBATCH --nodes=1

python /n05dat/yfwang/user/MarmosetWM/script/util/surf_2_asc_minds.py
