#!/bin/bash
#SBATCH --job-name=marmoset_hires_xtract
#SBATCH --output=log/marmoset_hires_xtract.%A_%a.out
#SBATCH --error=log/marmoset_hires_xtract.%A_%a.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --array=1,2,28,29,30,31,32,33

# af_l, af_r, slf1_l, slf1_r, slf2_l, slf2_r, slf3_l, slf3_r
# 1     2     28      29      30      31      32      33

arr=(`cat /n02dat01/users/yfwang/MarmosetWM/result/protocols_v1/fiberlist.txt`)
fiber=${arr[$SLURM_ARRAY_TASK_ID]}

WD=/gpfs/userdata/yfwang/MarmosetWM/result/hires_af_slf/xtract

if [ ! -f ${WD}/${fiber}/tractsInv/density.nii.gz ]; then
    bash ${WD}/commands2_${fiber}.txt
fi
