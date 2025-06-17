#!/bin/bash

NumofThreads=16

# atlaspath=/n05dat/yfwang/backup_marmoset/marmoset_MBM_raw/MBMv2/Marmoset_Brain_Mapping_v2.1.2_20200131
# datapath=/n05dat/yfwang/backup_marmoset/marmoset_MBM_raw/MBMv2/DMRI_80um_DWI_Preprocessed_TORTOISE
# resultpath=/n05dat/yfwang/user/MarmosetWM/result

# ## find ROI
# mkdir -p ${resultpath}/hires_validation/dorsal_validation/ROI
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 31 -uthr 31 -bin ${resultpath}/hires_validation/dorsal_validation/ROI/MBM_A45.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 57 -uthr 57 -bin ${resultpath}/hires_validation/dorsal_validation/ROI/MBM_AuCM.nii.gz
# fslmaths ${atlaspath}/MBM_cortex_vPaxinos_80um.nii.gz -thr 124 -uthr 124 -bin ${resultpath}/hires_validation/dorsal_validation/ROI/MBM_Tpt.nii.gz

# for roi in A45 AuCM Tpt; do
#     antsApplyTransforms -d 3 \
#                         -i ${resultpath}/hires_validation/dorsal_validation/ROI/MBM_${roi}.nii.gz \
#                         -o ${resultpath}/hires_validation/dorsal_validation/ROI/MBM_${roi}.nii.gz \
#                         -r ${datapath}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
#                         -t ${resultpath}/affine/FA80temp_80indi/FA1Warp.nii.gz \
#                         -t ${resultpath}/affine/FA80temp_80indi/FA0GenericAffine.mat \
#                         -n NearestNeighbor
#     fslmaths ${resultpath}/hires_validation/dorsal_validation/ROI/MBM_${roi}.nii.gz -mas ${resultpath}/hires_validation/dorsal_validation/mask_left.nii.gz ${resultpath}/hires_validation/dorsal_validation/ROI/MBM_${roi}_left.nii.gz
#     fslmaths ${resultpath}/hires_validation/dorsal_validation/ROI/MBM_${roi}.nii.gz -mas ${resultpath}/hires_validation/dorsal_validation/mask_right.nii.gz ${resultpath}/hires_validation/dorsal_validation/ROI/MBM_${roi}_right.nii.gz
# done


# ## tracking
resultpath=/n05dat/yfwang/user/MarmosetWM/result/hires_validation/dorsal_validation
tracking_resultpath=${resultpath}/tracking_1k_2

# for ROI1 in A45; do
#     for ROI2 in Tpt AuCM; do
#         for hemi in left right; do
#             for angle in 30 45 60; do
#                 tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
#                        -seed_image ${resultpath}/ROI/MBM_${ROI1}_${hemi}.nii.gz \
#                        -include ${resultpath}/ROI/MBM_${ROI2}_${hemi}.nii.gz \
#                        -mask ${datapath}/mask.nii.gz \
#                        ${resultpath}/fod_masked_${hemi}.mif \
#                        ${tracking_resultpath}/${ROI1}_${ROI2}_a${angle}_${hemi}.tck \
#                        -force -nthreads $NumofThreads
#             done

#             tckedit ${tracking_resultpath}/${ROI1}_${ROI2}_a30_${hemi}.tck \
#                     ${tracking_resultpath}/${ROI1}_${ROI2}_a45_${hemi}.tck \
#                     ${tracking_resultpath}/${ROI1}_${ROI2}_a60_${hemi}.tck \
#                     ${tracking_resultpath}/${ROI1}_${ROI2}_${hemi}.tck \
#                     -force -nthread $NumofThreads
#             tckmap ${tracking_resultpath}/${ROI1}_${ROI2}_${hemi}.tck \
#                    ${tracking_resultpath}/${ROI1}_${ROI2}_${hemi}.nii.gz \
#                    -template ${resultpath}/fod_masked_${hemi}.mif \
#                    -force -nthread $NumofThreads
#         done
#     done
# done

# for ROI1 in Tpt AuCM; do
#     for ROI2 in A45; do
#         for hemi in left right; do
#             for angle in 30 45 60; do
#                 tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
#                        -seed_image ${resultpath}/ROI/MBM_${ROI1}_${hemi}.nii.gz \
#                        -include ${resultpath}/ROI/MBM_${ROI2}_${hemi}.nii.gz \
#                        -mask ${datapath}/mask.nii.gz \
#                        ${resultpath}/fod_masked_${hemi}.mif \
#                        ${tracking_resultpath}/${ROI1}_${ROI2}_a${angle}_${hemi}.tck \
#                        -force -nthreads $NumofThreads
#             done

#             tckedit ${tracking_resultpath}/${ROI1}_${ROI2}_a30_${hemi}.tck \
#                     ${tracking_resultpath}/${ROI1}_${ROI2}_a45_${hemi}.tck \
#                     ${tracking_resultpath}/${ROI1}_${ROI2}_a60_${hemi}.tck \
#                     ${tracking_resultpath}/${ROI1}_${ROI2}_${hemi}.tck \
#                     -force -nthread $NumofThreads
#             tckmap ${tracking_resultpath}/${ROI1}_${ROI2}_${hemi}.tck \
#                    ${tracking_resultpath}/${ROI1}_${ROI2}_${hemi}.nii.gz \
#                    -template ${resultpath}/fod_masked_${hemi}.mif \
#                    -force -nthread $NumofThreads
#         done
#     done
# done

mkdir -p ${tracking_resultpath}_average
for hemi in left right; do

    fslmerge -t ${tracking_resultpath}_average/A45_AuCM_${hemi}.nii.gz \
             ${tracking_resultpath}/A45_AuCM_${hemi}.nii.gz \
             ${tracking_resultpath}/AuCM_A45_${hemi}.nii.gz
    fslmaths ${tracking_resultpath}_average/A45_AuCM_${hemi}.nii.gz -Tmean ${tracking_resultpath}_average/A45_AuCM_${hemi}.nii.gz
    fslmaths ${tracking_resultpath}_average/A45_AuCM_${hemi}.nii.gz -bin ${tracking_resultpath}_average/A45_AuCM_${hemi}_bin.nii.gz

    fslmerge -t ${tracking_resultpath}_average/A45_Tpt_${hemi}.nii.gz \
             ${tracking_resultpath}/A45_Tpt_${hemi}.nii.gz \
             ${tracking_resultpath}/Tpt_A45_${hemi}.nii.gz
    fslmaths ${tracking_resultpath}_average/A45_Tpt_${hemi}.nii.gz -Tmean ${tracking_resultpath}_average/A45_Tpt_${hemi}.nii.gz
    fslmaths ${tracking_resultpath}_average/A45_Tpt_${hemi}.nii.gz -bin ${tracking_resultpath}_average/A45_Tpt_${hemi}_bin.nii.gz

done





####################################################################################################

# # B.3. MRtrix3-based pipeline for dMRI tractography (by MRtrix3)
# # Note: Our 80 μm dMRI data used b = 0, b = 2400, and b = 4800 s/mm2

# # B.3.1. Multi-tissue constrained spherical deconvolution
# mrconvert data.nii.gz data.mif -fslgrad bvecs bvals -force -nthread $NumofThreads
# dwi2response manual data.mif WM_manual_selected_voxels.nii.gz WM.res -mask mask.nii.gz -lmax 0,6,10 -force -nthread $NumofThreads
# dwi2response manual data.mif GM_manual_selected_voxels.nii.gz GM.res -mask mask.nii.gz -lmax 0,0,0 -force -nthread $NumofThreads
# dwi2fod msmt_csd data.mif WM.res fod_WM.mif GM.res fod_GM.mif -mask mask.nii.gz -force -nthread $NumofThreads
# mrcalc fod_WM.mif mask_righthalf.nii.gz -mult fod_masked.mif -force -nthread $NumofThreads
# # Note1: WM_manual_selected_voxels and GM_manual_selected_voxels are manually defined. You may also use other automatic methods in dwi2response.
# # Note2: To reduce RAM and CPU requirements in dwi2fod, we removed many gray matter voxels using a conservative threshold (FOD < 0.05) and the left hemisphere. If you have time, or a very powerful computer, you can ignore this step.

# # B.3.2.a. Tractography for reconstructing white matter tracts of interest (e.g., see Fig. 7)
# # Note: We combined the tracking results with different angles (30,45,60). In addition, the tracking results are affected by which ROI is used as the seed. Thus, we used different inclusion masks as seeds and combined all those results as well. As different trackings may use different number of inclusion masks, we used ROI# to reset this variable here.
# tckgen -stop -select 5k -angle 30 -maxlength 75 -seed_image seed_ROI1.nii.gz -include include_ROI1.nii.gz -include include_ROI#.nii.gz -exclude exclude_ROI1.nii.gz -exclude exclude_ROI#.nii.gz -mask mask.nii.gz fod_masked.mif tracks_5K_ROI_a30_p1.tck -force -nthreads $NumofThreads
# tckgen -stop -select 5k -angle 45 -maxlength 75 -seed_image seed_ROI1.nii.gz -include include_ROI1.nii.gz -include include_ROI#.nii.gz -exclude exclude_ROI1.nii.gz -exclude exclude_ROI#.nii.gz -mask mask.nii.gz fod_masked.mif tracks_5K_ROI_a45_p1.tck -force -nthreads $NumofThreads
# tckgen -stop -select 5k -angle 60 -maxlength 75 -seed_image seed_ROI1.nii.gz -include include_ROI1.nii.gz -include include_ROI#.nii.gz -exclude exclude_ROI1.nii.gz -exclude exclude_ROI#.nii.gz -mask mask.nii.gz fod_masked.mif tracks_5K_ROI_a60_p1.tck -force -nthreads $NumofThreads
# tckgen -stop -select 5k -angle 30 -maxlength 75 -seed_image seed_ROI#.nii.gz -include include_ROI1.nii.gz -include include_ROI#.nii.gz -exclude exclude_ROI1.nii.gz -exclude exclude_ROI#.nii.gz -mask mask.nii.gz fod_masked.mif tracks_5K_ROI_a30_p#.tck -force -nthreads $NumofThreads
# tckgen -stop -select 5k -angle 45 -maxlength 75 -seed_image seed_ROI#.nii.gz -include include_ROI1.nii.gz -include include_ROI#.nii.gz -exclude exclude_ROI1.nii.gz -exclude exclude_ROI#.nii.gz -mask mask.nii.gz fod_masked.mif tracks_5K_ROI_a45_p#.tck -force -nthreads $NumofThreads
# tckgen -stop -select 5k -angle 60 -maxlength 75 -seed_image seed_ROI#.nii.gz -include include_ROI1.nii.gz -include include_ROI#.nii.gz -exclude exclude_ROI1.nii.gz -exclude exclude_ROI#.nii.gz -mask mask.nii.gz fod_masked.mif tracks_5K_ROI_a60_p#.tck -force -nthreads $NumofThreads
# tckedit tracks_5K_ROI_a30_p1.tck tracks_5K_ROI_a45_p1.tck tracks_5K_ROI_a60_p1.tck tracks_5K_ROI_a30_p#.tck tracks_5K_ROI_a45_p#.tck tracks_5K_ROI_a60_p#.tck tracks_all_ROI.tck -force -nthread $NumofThreads
# tckmap tracks_all_ROI.tck tracks_all_ROI.nii.gz -template fod_masked.mif -force -nthread $NumofThreads

# # B.3.2.b. Tractography for reconstructing white matter tracts of interest (e.g., see Fig. 8)
# # Note: ROI${i} and ROI${j} were two connected cortical regions in the neuronal-tracing database
# tckgen -stop -select 1k -angle 30 -maxlength 75 -seed_image ROI${i}.nii.gz -include ROI${j}.nii.gz -mask mask.nii.gz fod_masked.mif ROI${i}toROI${j}_a30.tck -force -nthreads $NumofThreads
# tckgen -stop -select 1k -angle 45 -maxlength 75 -seed_image ROI${i}.nii.gz -include ROI${j}.nii.gz -mask mask.nii.gz fod_masked.mif ROI${i}toROI${j}_a45.tck -force -nthreads $NumofThreads
# tckgen -stop -select 1k -angle 60 -maxlength 75 -seed_image ROI${i}.nii.gz -include ROI${j}.nii.gz -mask mask.nii.gz fod_masked.mif ROI${i}toROI${j}_a60.tck -force -nthreads $NumofThreads
# tckedit ROI${i}toROI${j}_a30.tck ROI${i}toROI${j}_a45.tck ROI${i}toROI${j}_a60.tck ROI${i}toROI${j}.tck
# tckmap ROI${i}toROI${j}.tck ROI${i}toROI${j}.nii.gz -template fod_masked.mif -force -nthread $NumofThreads
