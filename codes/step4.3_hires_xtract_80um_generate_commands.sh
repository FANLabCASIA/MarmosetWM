#!/bin/bash
#SBATCH --job-name=marmoset_high_res_xtract_80um
#SBATCH --output=log/marmoset_high_res_xtract_80um.%j.out
#SBATCH --error=log/marmoset_high_res_xtract_80um.%j.out
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --exclude=n19

resultpath=/n02dat01/users/yfwang/MarmosetWM/result

if [ -d ${resultpath}/hires_validation/xtract_all ]; then
    rm -rf ${resultpath}/hires_validation/xtract_all
fi

./xtract_ants_80um -bpx /n02dat01/users/yfwang/Data/marmoset_80um/DTI.bedpostX \
                   -out ${resultpath}/hires_validation/xtract_all \
                   -species CUSTOM \
                   -str ${resultpath}/protocols_v1/structureList \
                   -p ${resultpath}/protocols_v1 \
                   -ants ${resultpath}/affine/FA200temp_80indi/FA0GenericAffine.mat \
                   -stdwarp  ${resultpath}/affine/FA200temp_80indi/FA1InverseWarp.nii.gz ${resultpath}/affine/FA200temp_80indi/FA1Warp.nii.gz \
                   -pthr 0.1 \
                   -stdref /n02dat01/users/yfwang/MarmosetWM/support_data/template_DTI_FA_brain.nii.gz \
                   -native
