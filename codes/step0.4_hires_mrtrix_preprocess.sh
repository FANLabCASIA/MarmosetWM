#!/bin/bash

NumofThreads=16

path_80=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv2/Marmoset_Brain_Mapping_v2.1.2_20200131
data_80=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv2/DMRI_80um_DWI_Preprocessed_TORTOISE

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/hires_tracking

## register cortical+subcortical mask as GM mask and wm123 mask as WM mask to 80um individual brain by ANTs established previously
mkdir -p ${resultpath}/mrtrix_preprocessed

cp ${data_80}/mask.nii.gz ${resultpath}/mrtrix_preprocessed

fslmaths ${path_80}/MBM_cortex_vL_80um.nii.gz \
         -add ${path_80}/MBM_subcortical_beta_80um.nii.gz -bin \
         ${resultpath}/mrtrix_preprocessed/GM_manual_selected_voxels.nii.gz

fslmaths ${path_80}/MBM_wm_ROIs_1_80um.nii.gz \
         -add ${path_80}/MBM_wm_ROIs_2_80um.nii.gz \
         -add ${path_80}/MBM_wm_ROIs_3_80um.nii.gz -bin \
         ${resultpath}/mrtrix_preprocessed/WM_manual_selected_voxels.nii.gz

antsApplyTransforms -d 3 \
                    -i ${resultpath}/mrtrix_preprocessed/GM_manual_selected_voxels.nii.gz \
                    -o ${resultpath}/mrtrix_preprocessed/GM_manual_selected_voxels.nii.gz \
                    -r ${data_80}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                    -t ${resultpath}/affine/FA80temp_80indi/FA1Warp.nii.gz \
                    -t ${resultpath}/affine/FA80temp_80indi/FA0GenericAffine.mat \
                    -n NearestNeighbor

antsApplyTransforms -d 3 \
                    -i ${resultpath}/mrtrix_preprocessed/WM_manual_selected_voxels.nii.gz \
                    -o ${resultpath}/mrtrix_preprocessed/WM_manual_selected_voxels.nii.gz \
                    -r ${data_80}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                    -t ${resultpath}/affine/FA80temp_80indi/FA1Warp.nii.gz \
                    -t ${resultpath}/affine/FA80temp_80indi/FA0GenericAffine.mat \
                    -n NearestNeighbor

## mrtrix preprocess
mrconvert ${data_80}/data.nii.gz ${resultpath}/mrtrix_preprocessed/data.mif -fslgrad ${data_80}/bvecs ${data_80}/bvals -force -nthread $NumofThreads
dwiextract ${resultpath}/mrtrix_preprocessed/data.mif -shells 0,2400,4800 ${resultpath}/mrtrix_preprocessed/data_selected.mif # -export_grad_fsl bvecs_path bvals_path 

dwi2response manual ${resultpath}/mrtrix_preprocessed/data_selected.mif ${resultpath}/mrtrix_preprocessed/WM_manual_selected_voxels.nii.gz ${resultpath}/mrtrix_preprocessed/WM.res -mask ${data_80}/mask.nii.gz -lmax 0,6,10 -force -nthread $NumofThreads
dwi2response manual ${resultpath}/mrtrix_preprocessed/data_selected.mif ${resultpath}/mrtrix_preprocessed/GM_manual_selected_voxels.nii.gz ${resultpath}/mrtrix_preprocessed/GM.res -mask ${data_80}/mask.nii.gz -lmax 0,0,0 -force -nthread $NumofThreads
dwi2fod msmt_csd ${resultpath}/mrtrix_preprocessed/data_selected.mif ${resultpath}/mrtrix_preprocessed/WM.res ${resultpath}/mrtrix_preprocessed/fod_WM.mif ${resultpath}/mrtrix_preprocessed/GM.res ${resultpath}/mrtrix_preprocessed/fod_GM.mif -mask ${data_80}/mask.nii.gz -force -nthread $NumofThreads

## calculate left/right only data
for hemi in left right; do

    antsApplyTransforms -d 3 \
                        -i ${path_80}/MBM_mask_${hemi}_80um.nii.gz \
                        -o ${resultpath}/mrtrix_preprocessed/mask_${hemi}.nii.gz \
                        -r ${data_80}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                        -t ${resultpath}/affine/FA80temp_80indi/FA1Warp.nii.gz \
                        -t ${resultpath}/affine/FA80temp_80indi/FA0GenericAffine.mat \
                        -n NearestNeighbor

    mrcalc ${resultpath}/mrtrix_preprocessed/fod_WM.mif ${resultpath}/mrtrix_preprocessed/mask_${hemi}.nii.gz -mult ${resultpath}/mrtrix_preprocessed/fod_masked_${hemi}.mif -force -nthread $NumofThreads
done
