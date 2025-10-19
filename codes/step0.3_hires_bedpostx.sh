#!/bin/bash
#SBATCH --job-name=marmoset_hires_bedpostx
#SBATCH --output=log/marmoset_hires_bedpostx.%j.out
#SBATCH --error=log/marmoset_hires_bedpostx.%j.out
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1

data_80=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv2/DMRI_80um_DWI_Preprocessed_TORTOISE

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/hires_tracking
mkdir -p ${resultpath}/DTI

cp ${data_80}/data.nii.gz ${resultpath}/DTI
cp ${data_80}/mask.nii.gz ${resultpath}/DTI/nodif_brain_mask.nii.gz
cp ${data_80}/bvals ${resultpath}/DTI
cp ${data_80}/bvecs ${resultpath}/DTI

fslroi ${resultpath}/DTI/data.nii.gz ${resultpath}/DTI/nodif_brain.nii.gz 0 1
fslmaths ${resultpath}/DTI/nodif_brain.nii.gz -mas ${resultpath}/DTI/nodif_brain_mask.nii.gz ${resultpath}/DTI/nodif_brain.nii.gz

${FSLDIR}/bin/bedpostx_gpu ${resultpath}/DTI
