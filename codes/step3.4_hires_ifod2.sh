#!/bin/bash
#SBATCH --job-name=marmoset_hires_ifod2
#SBATCH --output=marmoset_hires_ifod2.%A_%a.out
#SBATCH --error=marmoset_hires_ifod2.%A_%a.out
#SBATCH --partition=cpu
#SBATCH --array=0-7

arr=(af_l af_r slf1_l slf1_r slf2_l slf2_r slf3_l slf3_r)
tract=${arr[$SLURM_ARRAY_TASK_ID]}

NumofThreads=16

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result

echo ${tract}
mkdir -p ${resultpath}/hires_af_slf/ifod2/${tract}

for angle in 30 45 60; do

    tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
           -seed_image ${resultpath}/hires_af_slf/masks/${tract}/seed.nii.gz \
           -include ${resultpath}/hires_af_slf/masks/${tract}/target1.nii.gz \
           -include ${resultpath}/hires_af_slf/masks/${tract}/target2.nii.gz \
           -exclude ${resultpath}/hires_af_slf/masks/${tract}/exclude.nii.gz \
           -mask ${resultpath}/hires_tracking/mrtrix_preprocessed/mask.nii.gz \
           ${resultpath}/hires_tracking/mrtrix_preprocessed/fod_WM.mif \
           ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a${angle}_forward.tck \
           -force -nthreads $NumofThreads

    tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
           -seed_image ${resultpath}/hires_af_slf/masks/${tract}/target1.nii.gz \
           -seed_image ${resultpath}/hires_af_slf/masks/${tract}/target2.nii.gz \
           -include ${resultpath}/hires_af_slf/masks/${tract}/seed.nii.gz \
           -exclude ${resultpath}/hires_af_slf/masks/${tract}/exclude.nii.gz \
           -mask ${resultpath}/hires_tracking/mrtrix_preprocessed/mask.nii.gz \
           ${resultpath}/hires_tracking/mrtrix_preprocessed/fod_WM.mif \
           ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a${angle}_backward.tck \
           -force -nthreads $NumofThreads

    #  tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
    #         -seed_image ${resultpath}/hires_af_slf/masks/${tract}/target1.nii.gz \
    #         -include ${resultpath}/hires_af_slf/masks/${tract}/target2.nii.gz \
    #         -include ${resultpath}/hires_af_slf/masks/${tract}/seed.nii.gz \
    #         -exclude ${resultpath}/hires_af_slf/masks/${tract}/exclude.nii.gz \
    #         -mask ${resultpath}/hires_tracking/mrtrix_preprocessed/mask.nii.gz \
    #         ${resultpath}/hires_tracking/mrtrix_preprocessed/fod_WM.mif \
    #         ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a${angle}_backward1.tck \
    #         -force -nthreads $NumofThreads

    #  tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
    #         -seed_image ${resultpath}/hires_af_slf/masks/${tract}/target2.nii.gz \
    #         -include ${resultpath}/hires_af_slf/masks/${tract}/target1.nii.gz \
    #         -include ${resultpath}/hires_af_slf/masks/${tract}/seed.nii.gz \
    #         -exclude ${resultpath}/hires_af_slf/masks/${tract}/exclude.nii.gz \
    #         -mask ${resultpath}/hires_tracking/mrtrix_preprocessed/mask.nii.gz \
    #         ${resultpath}/hires_tracking/mrtrix_preprocessed/fod_WM.mif \
    #         ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a${angle}_backward2.tck \
    #         -force -nthreads $NumofThreads
done

# add together
tckedit ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a30_forward.tck \
        ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a45_forward.tck \
        ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a60_forward.tck \
        ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_forward.tck \
        -force -nthread $NumofThreads

tckedit ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a30_backward.tck \
        ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a45_backward.tck \
        ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a60_backward.tck \
        ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward.tck \
        -force -nthread $NumofThreads

# tckedit ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a30_backward1.tck \
#         ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a45_backward1.tck \
#         ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a60_backward1.tck \
#         ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward1.tck \
#         -force -nthread $NumofThreads

# tckedit ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a30_backward2.tck \
#         ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a45_backward2.tck \
#         ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_a60_backward2.tck \
#         ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward2.tck \
#         -force -nthread $NumofThreads

# add forward and backward
tckedit ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_forward.tck \
        ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward.tck \
        ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}.tck \
        -force -nthread $NumofThreads

# tckedit ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_forward.tck \
#         ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward1.tck \
#         ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward2.tck \
#         ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}.tck \
#         -force -nthread $NumofThreads

# map to the nifti
tckmap ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_forward.tck \
       ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_forward.nii.gz \
       -template ${resultpath}/hires_tracking/mrtrix_preprocessed/fod_WM.mif \
       -force -nthread $NumofThreads

tckmap ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward.tck \
       ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward.nii.gz \
       -template ${resultpath}/hires_tracking/mrtrix_preprocessed/fod_WM.mif \
       -force -nthread $NumofThreads

# tckmap ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward1.tck \
#        ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward1.nii.gz \
#        -template ${resultpath}/hires_tracking/mrtrix_preprocessed/fod_WM.mif \
#        -force -nthread $NumofThreads

# tckmap ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward2.tck \
#        ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward2.nii.gz \
#        -template ${resultpath}/hires_tracking/mrtrix_preprocessed/fod_WM.mif \
#        -force -nthread $NumofThreads

tckmap ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}.tck \
       ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}.nii.gz \
       -template ${resultpath}/hires_tracking/mrtrix_preprocessed/fod_WM.mif \
       -force -nthread $NumofThreads

# average across two running tracking
fslmerge -t ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_average.nii.gz \
            ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_forward.nii.gz \
            ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward.nii.gz

# fslmerge -t ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_average.nii.gz \
#             ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_forward.nii.gz \
#             ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward1.nii.gz \
#             ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_backward2.nii.gz

fslmaths ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_average.nii.gz \
         -Tmean ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_average.nii.gz

fslmaths ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_average.nii.gz \
         -bin ${resultpath}/hires_af_slf/ifod2/${tract}/${tract}_average_bin.nii.gz
