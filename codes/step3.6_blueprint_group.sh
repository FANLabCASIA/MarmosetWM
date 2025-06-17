#!/bin/bash
#SBATCH --job-name=marmoset_fiber_projection
#SBATCH --output=log/marmoset_fiber_projection.%j.out
#SBATCH --error=log/marmoset_fiber_projection.%j.out
#SBATCH --partition=cpu
#SBATCH --exclude=n05,n15

matlab -nodisplay -nosplash -r "addpath(genpath('/n02dat01/users/yfwang/MarmosetWM/script/util')); average_blueprint; exit"
matlab -nodisplay -nosplash -r "addpath(genpath('/n05dat/yfwang/user/MarmosetWM/script/util')); average_blueprint_minds; exit"
