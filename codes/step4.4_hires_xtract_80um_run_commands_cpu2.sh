#!/bin/bash
#SBATCH --job-name=xtract2_80um
#SBATCH --output=log/xtract2_80um.%A_%a.out
#SBATCH --error=log/xtract2_80um.%A_%a.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#\\SBATCH --array=0-43

# af_l 1
# af_r 2
# slf1_l 28
# slf1_r 29
# slf2_l 30
# slf2_r 31
# slf3_l 32
# slf3_r 33

arr=(`cat /n02dat01/users/yfwang/MarmosetWM/result/protocols_v1/fiberlist.txt`)
fiber=${arr[$SLURM_ARRAY_TASK_ID]}

subdir=/n02dat01/users/yfwang/MarmosetWM/result/hires_validation

if [ ! -f ${subdir}/xtract_all/tracts/${fiber}/tractsInv/density.nii.gz ]; then
    bash ${subdir}/xtract_all/commands2_${fiber}.txt
fi
