#!/bin/bash
#SBATCH --job-name=dv
#SBATCH --output=log/dv.%j.out
#SBATCH --error=log/dv.%j.out
#SBATCH --partition=cpu
#SBATCH --nodes=1

atlaspath=/n05dat/yfwang/backup_marmoset/marmoset_MBM_raw/MBMv2/Marmoset_Brain_Mapping_v2.1.2_20200131
datapath=/n05dat/yfwang/backup_marmoset/marmoset_80um
resultpath=/n05dat/yfwang/user/MarmosetWM/result

# ###########
# ## find ROI
# ###########
# mkdir -p ${resultpath}/hires_validation/dorsal_validation/ROI_mask
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 54 -uthr 54 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuA1.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 55 -uthr 55 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuAL.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 56 -uthr 56 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuCL.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 57 -uthr 57 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuCM.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 58 -uthr 58 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuCPB.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 59 -uthr 59 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuML.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 60 -uthr 60 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuR.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 61 -uthr 61 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuRM.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 62 -uthr 62 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuRPB.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 63 -uthr 63 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuRT.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 64 -uthr 64 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuRTL.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 65 -uthr 65 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_AuRTM.nii.gz

# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 67 -uthr 67 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_DI.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 72 -uthr 72 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_GI.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 73 -uthr 73 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_Gu.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 75 -uthr 75 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_Ipro.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 96 -uthr 96 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_PalL.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 97 -uthr 97 -bin ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_PalM.nii.gz

# for roi in AuA1 AuAL AuCL AuCM AuCPB AuML AuR AuRM AuRPB AuRT AuRTL AuRTM DI GI Gu Ipro PalL PalM; do
#     antsApplyTransforms -d 3 \
#                         -i ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_${roi}.nii.gz \
#                         -o ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_${roi}.nii.gz \
#                         -r ${datapath}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
#                         -t ${resultpath}/affine/FA80temp_80indi/FA1Warp.nii.gz \
#                         -t ${resultpath}/affine/FA80temp_80indi/FA0GenericAffine.mat \
#                         -n NearestNeighbor
#     fslmaths ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_${roi}.nii.gz -mas ${resultpath}/hires_validation/dorsal_validation/mask_left.nii.gz ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_${roi}_left.nii.gz
#     # fslmaths ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_${roi}.nii.gz -mas ${resultpath}/hires_validation/dorsal_validation/mask_right.nii.gz ${resultpath}/hires_validation/dorsal_validation/ROI_mask/MBM_${roi}_right.nii.gz
# done


#####################
## dorsal vs. ventral
#####################
resultpath=/n05dat/yfwang/user/MarmosetWM/result/hires_validation/dorsal_validation

mask_dorsal_left=${resultpath}/ROI_mask/dorsal_left.nii.gz
mask_dorsal_right=${resultpath}/ROI_mask/dorsal_right.nii.gz
mask_ventral_left=${resultpath}/ROI_mask/ventral_left.nii.gz
mask_ventral_right=${resultpath}/ROI_mask/ventral_right.nii.gz

tracking_resultpath=${resultpath}/tracking_1k_2

# A45 - AuCM
echo "A45 - AuCM left"
tckedit ${tracking_resultpath}/A45_AuCM_left.tck -include ${mask_dorsal_left} ${tracking_resultpath}/A45_AuCM_left_dorsal.tck -force
tckedit ${tracking_resultpath}/A45_AuCM_left.tck -include ${mask_ventral_left} ${tracking_resultpath}/A45_AuCM_left_ventral.tck -force

tckedit ${tracking_resultpath}/AuCM_A45_left.tck -include ${mask_dorsal_left} ${tracking_resultpath}/AuCM_A45_left_dorsal.tck -force
tckedit ${tracking_resultpath}/AuCM_A45_left.tck -include ${mask_ventral_left} ${tracking_resultpath}/AuCM_A45_left_ventral.tck -force

echo "A45 - AuCM right"
tckedit ${tracking_resultpath}/A45_AuCM_right.tck -include ${mask_dorsal_right} ${tracking_resultpath}/A45_AuCM_right_dorsal.tck -force
tckedit ${tracking_resultpath}/A45_AuCM_right.tck -include ${mask_ventral_right} ${tracking_resultpath}/A45_AuCM_right_ventral.tck -force

tckedit ${tracking_resultpath}/AuCM_A45_right.tck -include ${mask_dorsal_right} ${tracking_resultpath}/AuCM_A45_right_dorsal.tck -force
tckedit ${tracking_resultpath}/AuCM_A45_right.tck -include ${mask_ventral_right} ${tracking_resultpath}/AuCM_A45_right_ventral.tck -force

# A45 - Tpt
echo "A45 - Tpt left"
tckedit ${tracking_resultpath}/A45_Tpt_left.tck -include ${mask_dorsal_left} ${tracking_resultpath}/A45_Tpt_left_dorsal.tck -force
tckedit ${tracking_resultpath}/A45_Tpt_left.tck -include ${mask_ventral_left} ${tracking_resultpath}/A45_Tpt_left_ventral.tck -force

tckedit ${tracking_resultpath}/Tpt_A45_left.tck -include ${mask_dorsal_left} ${tracking_resultpath}/Tpt_A45_left_dorsal.tck -force
tckedit ${tracking_resultpath}/Tpt_A45_left.tck -include ${mask_ventral_left} ${tracking_resultpath}/Tpt_A45_left_ventral.tck -force

echo "A45 - Tpt right"
tckedit ${tracking_resultpath}/A45_Tpt_right.tck -include ${mask_dorsal_right} ${tracking_resultpath}/A45_Tpt_right_dorsal.tck -force
tckedit ${tracking_resultpath}/A45_Tpt_right.tck -include ${mask_ventral_right} ${tracking_resultpath}/A45_Tpt_right_ventral.tck -force

tckedit ${tracking_resultpath}/Tpt_A45_right.tck -include ${mask_dorsal_right} ${tracking_resultpath}/Tpt_A45_right_dorsal.tck -force
tckedit ${tracking_resultpath}/Tpt_A45_right.tck -include ${mask_ventral_right} ${tracking_resultpath}/Tpt_A45_right_ventral.tck -force
