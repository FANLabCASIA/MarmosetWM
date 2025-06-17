#!/bin/bash
#SBATCH -J bed
#SBATCH -o bed.%j.out
#SBATCH -e bed.%j.out
#SBATCH -p gpu
#SBATCH --nodelist=n19
#SBATCH --gres=gpu:1

${FSLDIR}/bin/bedpostx_gpu /n02dat01/users/yfwang/Data/chimp_ecb/dMRI
