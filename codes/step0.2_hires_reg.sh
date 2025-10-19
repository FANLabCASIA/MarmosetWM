#!/bin/bash
#SBATCH --job-name=marmoset_hires_reg
#SBATCH --output=log/marmoset_hires_reg.%j.out
#SBATCH --error=log/marmoset_hires_reg.%j.out
#SBATCH --partition=cpu

data_80=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv2/DMRI_80um_DWI_Preprocessed_TORTOISE
path_80=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv2/Marmoset_Brain_Mapping_v2.1.2_20200131
path_200=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result

# 0.2mm template -> 80um indi
mkdir -p ${resultpath}/affine/FA200temp_80indi
antsRegistrationSyN.sh -d 3 \
                       -f ${path_200}/template_DTI_FA_brain.nii.gz \
                       -m ${data_80}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                       -o ${resultpath}/affine/FA200temp_80indi/FA

# 80um indi -> 80um template
mkdir -p ${resultpath}/affine/FA80indi_80temp
antsRegistrationSyN.sh -d 3 \
                       -f ${path_80}/Template_sym_FA_80um.nii.gz \
                       -m ${data_80}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                       -o ${resultpath}/affine/FA80indi_80temp/FA

# 80um template -> 80um indi
mkdir -p ${resultpath}/affine/FA80temp_80indi
antsRegistrationSyN.sh -d 3 \
                       -f ${data_80}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                       -m ${path_80}/Template_sym_FA_80um.nii.gz \
                       -o ${resultpath}/affine/FA80temp_80indi/FA
