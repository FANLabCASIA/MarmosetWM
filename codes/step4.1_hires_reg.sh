#!/bin/bash
#SBATCH --job-name=marmoset_high_res_reg
#SBATCH --output=log/marmoset_high_res_reg.%j.out
#SBATCH --error=log/marmoset_high_res_reg.%j.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --exclude=n05,n15


path_200=/n02dat01/users/yfwang/repo/marmoset_MBM/MBMv3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1

path_80_indi=/n02dat01/users/yfwang/repo/marmoset_MBM/MBMv2/DMRI_80um_DWI_Preprocessed_TORTOISE
path_80_temp=/n02dat01/users/yfwang/repo/marmoset_MBM/MBMv2/Marmoset_Brain_Mapping_v2.1.2_20200131

resultpath=/n02dat01/users/yfwang/MarmosetWM/result

# 0.2mm template -> 80um indi
mkdir -p ${resultpath}/affine/FA200temp_80indi
antsRegistrationSyN.sh -d 3 \
                       -f ${path_200}/template_DTI_FA_brain.nii.gz \
                       -m ${path_80_indi}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                       -o ${resultpath}/affine/FA200temp_80indi/FA

# 80um indi -> 80um template
mkdir -p ${resultpath}/affine/FA80indi_80temp
antsRegistrationSyN.sh -d 3 \
                       -f ${path_80_temp}/Template_sym_FA_80um.nii.gz \
                       -m ${path_80_indi}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                       -o ${resultpath}/affine/FA80indi_80temp/FA

# 80um template -> 80um indi
mkdir -p ${resultpath}/affine/FA80temp_80indi
antsRegistrationSyN.sh -d 3 \
                       -f ${path_80_indi}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                       -m ${path_80_temp}/Template_sym_FA_80um.nii.gz \
                       -o ${resultpath}/affine/FA80temp_80indi/FA

