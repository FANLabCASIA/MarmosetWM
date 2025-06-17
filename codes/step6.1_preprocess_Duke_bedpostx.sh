#!/bin/bash
#\\SBATCH -J bed
#\\SBATCH -o log/bed.%j.out
#\\SBATCH -e log/bed.%j.out
#\\SBATCH -p gpu
#\\SBATCH --nodelist=n19
#\\SBATCH --gres=gpu:1

${FSLDIR}/bin/bedpostx_gpu /n02dat01/users/yfwang/Data/Duke_Macaque_DTI/m30/DTI
