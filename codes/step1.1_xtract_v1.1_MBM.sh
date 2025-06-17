#!/bin/bash
#SBATCH --job-name=marmoset_xtract_v1.1_MBM
#SBATCH --output=log/marmoset_xtract_v1.1_MBM.%A_%a.out
#SBATCH --error=log/marmoset_xtract_v1.1_MBM.%A_%a.out
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --exclude=n19
#SBATCH --gres=gpu:1
#SBATCH --array=0-23%4


arr=(`cat /n02dat01/users/yfwang/Data/marmoset_MBM/marmoset_MBM_list.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

recipespath=/n02dat01/users/yfwang/MarmosetWM/result/protocols_v1.1
supportdatapath=/n02dat01/users/yfwang/MarmosetWM/support_data

datadir=/n02dat01/users/yfwang/Data/marmoset_MBM
subdir=/n02dat01/users/yfwang/MarmosetWM/result/xtract_result_v1.1_MBM/${sub}
mkdir -p ${subdir}
cp ${datadir}/${sub}/DTI/nodif_brain.nii.gz ${subdir}

if [ -d ${subdir}/xtract ]; then
    rm -rf ${subdir}/xtract
fi

./xtract_ants -bpx ${datadir}/${sub}/DTI.bedpostX \
              -out ${subdir}/xtract \
              -species CUSTOM \
              -str ${recipespath}/structureList \
              -p ${recipespath} \
              -ants ${datadir}/${sub}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat \
              -stdwarp  ${datadir}/${sub}/affine/ind2MBMv3/ind2MBMv31InverseWarp.nii.gz ${datadir}/${sub}/affine/ind2MBMv3/ind2MBMv31Warp.nii.gz \
              -pthr 0.1 \
              -stdref ${supportdatapath}/template_DTI_FA_brain.nii.gz \
              -native \
              -gpu

