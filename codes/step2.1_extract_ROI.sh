#!/bin/bash

NumofThreads=16

path_80=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv2/Marmoset_Brain_Mapping_v2.1.2_20200131
data_80=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv2/DMRI_80um_DWI_Preprocessed_TORTOISE

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result

## define the ROI
mkdir -p ${resultpath}/hires_tracking/ROI

# Paxinos atlas: A45, AuCM, Tpt
fslmaths ${path_80}/MBM_cortex_vPaxinos_80um.nii.gz -thr 31 -uthr 31 -bin ${resultpath}/hires_tracking/ROI/Paxinos_A45.nii.gz
fslmaths ${path_80}/MBM_cortex_vPaxinos_80um.nii.gz -thr 57 -uthr 57 -bin ${resultpath}/hires_tracking/ROI/Paxinos_AuCM.nii.gz
fslmaths ${path_80}/MBM_cortex_vPaxinos_80um.nii.gz -thr 124 -uthr 124 -bin ${resultpath}/hires_tracking/ROI/Paxinos_Tpt.nii.gz 

for roi in A45 AuCM Tpt; do

    antsApplyTransforms -d 3 \
                        -i ${resultpath}/hires_tracking/ROI/Paxinos_${roi}.nii.gz \
                        -o ${resultpath}/hires_tracking/ROI/Paxinos_${roi}.nii.gz \
                        -r ${data_80}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                        -t ${resultpath}/affine/FA80temp_80indi/FA1Warp.nii.gz \
                        -t ${resultpath}/affine/FA80temp_80indi/FA0GenericAffine.mat \
                        -n NearestNeighbor

    fslmaths ${resultpath}/ROI/Paxinos_${roi}.nii.gz -mas ${resultpath}/hires_tracking/mrtrix_preprocessed/mask_left.nii.gz ${resultpath}/ROI/Paxinos_${roi}_left.nii.gz
    fslmaths ${resultpath}/ROI/Paxinos_${roi}.nii.gz -mas ${resultpath}/hires_tracking/mrtrix_preprocessed/mask_right.nii.gz ${resultpath}/ROI/Paxinos_${roi}_right.nii.gz
done

# MBM atlas: A45, BeltM, Tpt
fslmaths ${path_80}/MBM_cortex_vH_80um.nii.gz -thr 8 -uthr 8 -bin ${resultpath}/hires_tracking/ROI/MBMvH_A45.nii.gz
fslmaths ${path_80}/MBM_cortex_vH_80um.nii.gz -thr 35 -uthr 35 -bin ${resultpath}/hires_tracking/ROI/MBMvH_BeltM.nii.gz
fslmaths ${path_80}/MBM_cortex_vH_80um.nii.gz -thr 46 -uthr 46 -bin ${resultpath}/hires_tracking/ROI/MBMvH_Tpt.nii.gz 

for roi in A45 BeltM Tpt; do

    antsApplyTransforms -d 3 \
                        -i ${resultpath}/hires_tracking/ROI/MBMvH_${roi}.nii.gz \
                        -o ${resultpath}/hires_tracking/ROI/MBMvH_${roi}.nii.gz \
                        -r ${data_80}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                        -t ${resultpath}/affine/FA80temp_80indi/FA1Warp.nii.gz \
                        -t ${resultpath}/affine/FA80temp_80indi/FA0GenericAffine.mat \
                        -n NearestNeighbor

    fslmaths ${resultpath}/ROI/MBMvH_${roi}.nii.gz -mas ${resultpath}/hires_tracking/mrtrix_preprocessed/mask_left.nii.gz ${resultpath}/ROI/MBMvH_${roi}_left.nii.gz
    fslmaths ${resultpath}/ROI/MBMvH_${roi}.nii.gz -mas ${resultpath}/hires_tracking/mrtrix_preprocessed/mask_right.nii.gz ${resultpath}/ROI/MBMvH_${roi}_right.nii.gz
done