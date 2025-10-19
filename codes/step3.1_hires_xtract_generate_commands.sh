#!/bin/bash
#SBATCH --job-name=marmoset_hires_xtract
#SBATCH --output=log/marmoset_hires_xtract.%j.out
#SBATCH --error=log/marmoset_hires_xtract.%j.out
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result
supportdatapath=/gpfs/userdata/yfwang/MarmosetWM/support_data

[ -d ${resultpath}/hires_af_slf/xtract ] && rm -rf ${resultpath}/hires_af_slf/xtract

./xtract_ants_80um -bpx ${resultpath}/hires_tracking/DTI.bedpostX \
                   -out ${resultpath}/hires_af_slf/xtract \
                   -species CUSTOM \
                   -str ${resultpath}/protocols/structureList \
                   -p ${resultpath}/protocols \
                   -ants ${resultpath}/affine/FA200temp_80indi/FA0GenericAffine.mat \
                   -stdwarp  ${resultpath}/affine/FA200temp_80indi/FA1InverseWarp.nii.gz ${resultpath}/affine/FA200temp_80indi/FA1Warp.nii.gz \
                   -pthr 0.1 \
                   -stdref ${supportdatapath}/template_DTI_FA_brain.nii.gz \
                   -native
