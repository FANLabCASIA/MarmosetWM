#!/bin/bash

NumofThreads=16

atlaspath=/n02dat01/users/yfwang/repo/marmoset_MBM/MBMv2/Marmoset_Brain_Mapping_v2.1.2_20200131
datapath=/n02dat01/users/yfwang/repo/marmoset_MBM/MBMv2/DMRI_80um_DWI_Preprocessed_TORTOISE
resultpath=/n02dat01/users/yfwang/MarmosetWM/result

## register cortical+subcortical mask as GM mask and wm123 mask as WM mask to 80um individual brain by ANTs established previously
fslmaths ${atlaspath}/MBM_cortex_vL_80um.nii.gz -add ${atlaspath}/MBM_subcortical_beta_80um.nii.gz -bin ${resultpath}/hires_validation/dorsal_validation/GM_manual_selected_voxels.nii.gz
fslmaths ${atlaspath}/MBM_wm_ROIs_1_80um.nii.gz -add ${atlaspath}/MBM_wm_ROIs_2_80um.nii.gz -add ${atlaspath}/MBM_wm_ROIs_3_80um.nii.gz -bin ${resultpath}/hires_validation/dorsal_validation/WM_manual_selected_voxels.nii.gz

antsApplyTransforms -d 3 \
                    -i ${resultpath}/hires_validation/dorsal_validation/GM_manual_selected_voxels.nii.gz \
                    -o ${resultpath}/hires_validation/dorsal_validation/GM_manual_selected_voxels.nii.gz \
                    -r ${datapath}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                    -t ${resultpath}/affine/FA80temp_80indi/FA1Warp.nii.gz \
                    -t ${resultpath}/affine/FA80temp_80indi/FA0GenericAffine.mat \
                    -n NearestNeighbor

antsApplyTransforms -d 3 \
                    -i ${resultpath}/hires_validation/dorsal_validation/WM_manual_selected_voxels.nii.gz \
                    -o ${resultpath}/hires_validation/dorsal_validation/WM_manual_selected_voxels.nii.gz \
                    -r ${datapath}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                    -t ${resultpath}/affine/FA80temp_80indi/FA1Warp.nii.gz \
                    -t ${resultpath}/affine/FA80temp_80indi/FA0GenericAffine.mat \
                    -n NearestNeighbor


## mrtrix process
mrconvert ${datapath}/data.nii.gz ${resultpath}/hires_validation/dorsal_validation/data.mif -fslgrad ${datapath}/bvecs ${datapath}/bvals -force -nthread $NumofThreads
dwiextract ${resultpath}/hires_validation/dorsal_validation/data.mif -shells 0,2400,4800 ${resultpath}/hires_validation/dorsal_validation/data_selected.mif # -export_grad_fsl bvecs_path bvals_path 

# dwi2response dhollander ${resultpath}/hires_validation/dorsal_validation/data_selected.mif ${resultpath}/hires_validation/dorsal_validation/WM.res ${resultpath}/hires_validation/dorsal_validation/GM.res  ${resultpath}/hires_validation/dorsal_validation/CSF.res -mask ${datapath}/mask.nii.gz -force -nthread $NumofThreads
# dwi2fod msmt_csd ${resultpath}/hires_validation/dorsal_validation/data_selected.mif ${resultpath}/hires_validation/dorsal_validation/WM.res ${resultpath}/hires_validation/dorsal_validation/fod_WM.mif ${resultpath}/hires_validation/dorsal_validation/GM.res ${resultpath}/hires_validation/dorsal_validation/fod_GM.mif ${resultpath}/hires_validation/dorsal_validation/CSF.res ${resultpath}/hires_validation/dorsal_validation/fod_CSF.mif -mask ${datapath}/mask.nii.gz -force -nthread $NumofThreads

dwi2response manual ${resultpath}/hires_validation/dorsal_validation/data_selected.mif ${resultpath}/hires_validation/dorsal_validation/WM_manual_selected_voxels.nii.gz ${resultpath}/hires_validation/dorsal_validation/WM.res -mask ${datapath}/mask.nii.gz -lmax 0,6,10 -force -nthread $NumofThreads
dwi2response manual ${resultpath}/hires_validation/dorsal_validation/data_selected.mif ${resultpath}/hires_validation/dorsal_validation/GM_manual_selected_voxels.nii.gz ${resultpath}/hires_validation/dorsal_validation/GM.res -mask ${datapath}/mask.nii.gz -lmax 0,0,0 -force -nthread $NumofThreads
dwi2fod msmt_csd ${resultpath}/hires_validation/dorsal_validation/data_selected.mif ${resultpath}/hires_validation/dorsal_validation/WM.res ${resultpath}/hires_validation/dorsal_validation/fod_WM.mif ${resultpath}/hires_validation/dorsal_validation/GM.res ${resultpath}/hires_validation/dorsal_validation/fod_GM.mif -mask ${datapath}/mask.nii.gz -force -nthread $NumofThreads


## calculate left/right only data
for hemi in left right; do

    antsApplyTransforms -d 3 \
                        -i ${atlaspath}/MBM_mask_${hemi}_80um.nii.gz \
                        -o ${resultpath}/hires_validation/dorsal_validation/mask_${hemi}.nii.gz \
                        -r ${datapath}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                        -t ${resultpath}/affine/FA80temp_80indi/FA1Warp.nii.gz \
                        -t ${resultpath}/affine/FA80temp_80indi/FA0GenericAffine.mat \
                        -n NearestNeighbor

    mrcalc ${resultpath}/hires_validation/dorsal_validation/fod_WM.mif ${resultpath}/hires_validation/dorsal_validation/mask_${hemi}.nii.gz -mult ${resultpath}/hires_validation/dorsal_validation/fod_masked_${hemi}.mif -force -nthread $NumofThreads
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
