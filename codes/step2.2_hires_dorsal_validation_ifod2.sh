#!/bin/bash
#SBATCH --job-name=marmoset_hires_dorsal_ifod2
#SBATCH --output=marmoset_hires_dorsal_ifod2.%j.out
#SBATCH --error=marmoset_hires_dorsal_ifod2.%j.out
#SBATCH --partition=ga10
#SBATCH --gres=gpu:1

NumofThreads=16

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/hires_tracking

mkdir -p ${resultpath}/dorsal_ifod2

for ROI1 in A45; do
    for ROI2 in Tpt AuCM; do
        for hemi in left right; do

            mkdir -p ${resultpath}/dorsal_ifod2/${ROI1}_${ROI2}_${hemi}
            mkdir -p ${resultpath}/dorsal_ifod2/${ROI2}_${ROI1}_${hemi}

            for angle in 30 45 60; do

                tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
                       -seed_image ${resultpath}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                       -include ${resultpath}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                       -mask ${resultpath}/mrtrix_preprocessed/mask.nii.gz \
                       ${resultpath}/mrtrix_preprocessed/fod_masked_${hemi}.mif \
                       ${resultpath}/dorsal_ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_a${angle}_${hemi}.tck \
                       -force -nthreads $NumofThreads

                tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
                       -seed_image ${resultpath}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                       -include ${resultpath}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                       -mask ${resultpath}/mrtrix_preprocessed/mask.nii.gz \
                       ${resultpath}/mrtrix_preprocessed/fod_masked_${hemi}.mif \
                       ${resultpath}/dorsal_ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_a${angle}_${hemi}.tck \
                       -force -nthreads $NumofThreads
            done

            tckedit ${resultpath}/dorsal_ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_a30_${hemi}.tck \
                    ${resultpath}/dorsal_ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_a45_${hemi}.tck \
                    ${resultpath}/dorsal_ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_a60_${hemi}.tck \
                    ${resultpath}/dorsal_ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}.tck \
                    -force -nthread $NumofThreads

            tckedit ${resultpath}/dorsal_ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_a30_${hemi}.tck \
                    ${resultpath}/dorsal_ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_a45_${hemi}.tck \
                    ${resultpath}/dorsal_ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_a60_${hemi}.tck \
                    ${resultpath}/dorsal_ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}.tck \
                    -force -nthread $NumofThreads

            tckmap ${resultpath}/dorsal_ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}.tck \
                   ${resultpath}/dorsal_ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}.nii.gz \
                   -template ${resultpath}/mrtrix_preprocessed/fod_masked_${hemi}.mif \
                   -force -nthread $NumofThreads

            tckmap ${resultpath}/dorsal_ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}.tck \
                   ${resultpath}/dorsal_ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}.nii.gz \
                   -template ${resultpath}/mrtrix_preprocessed/fod_masked_${hemi}.mif \
                   -force -nthread $NumofThreads
        done
    done
done


## average two probability maps
for hemi in left right; do

    fslmerge -t ${resultpath}/dorsal_ifod2/A45_AuCM_${hemi}.nii.gz \
             ${resultpath}/dorsal_ifod2/A45_AuCM_${hemi}/A45_AuCM_${hemi}.nii.gz \
             ${resultpath}/dorsal_ifod2/AuCM_A45_${hemi}/AuCM_A45_${hemi}.nii.gz
    fslmaths ${resultpath}/dorsal_ifod2/A45_AuCM_${hemi}.nii.gz -Tmean ${resultpath}/dorsal_ifod2/A45_AuCM_${hemi}.nii.gz
    fslmaths ${resultpath}/dorsal_ifod2/A45_AuCM_${hemi}.nii.gz -bin ${resultpath}/dorsal_ifod2/A45_AuCM_${hemi}_bin.nii.gz

    fslmerge -t ${resultpath}/dorsal_ifod2/A45_Tpt_${hemi}.nii.gz \
             ${resultpath}/dorsal_ifod2/A45_Tpt_${hemi}/A45_Tpt_${hemi}.nii.gz \
             ${resultpath}/dorsal_ifod2/Tpt_A45_${hemi}/Tpt_A45_${hemi}.nii.gz
    fslmaths ${resultpath}/dorsal_ifod2/A45_Tpt_${hemi}.nii.gz -Tmean ${resultpath}/dorsal_ifod2/A45_Tpt_${hemi}.nii.gz
    fslmaths ${resultpath}/dorsal_ifod2/A45_Tpt_${hemi}.nii.gz -bin ${resultpath}/dorsal_ifod2/A45_Tpt_${hemi}_bin.nii.gz

done


## comare dorsal and ventral pathway
for ROI1 in A45; do
    for ROI2 in AuCM Tpt; do
        for hemi in left right; do
            for pathway in dorsal ventral; do

                mask=${resultpath}/ROI/mask_${pathway}_${hemi}.nii.gz

                echo ${ROI1} - ${ROI2} - ${hemi} - ${pathway}
                tckedit ${resultpath}/dorsal_ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}.tck \
                        -include ${mask} \
                        ${resultpath}/dorsal_ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}_${pathway}.tck \
                        -force
                tckinfo ${resultpath}/dorsal_ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}_${pathway}.tck | grep count

                echo ${ROI2} - ${ROI1} - ${hemi} - ${pathway}
                tckedit ${resultpath}/dorsal_ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}.tck \
                        -include ${mask} \
                        ${resultpath}/dorsal_ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}_${pathway}.tck \
                        -force
                tckinfo ${resultpath}/dorsal_ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}_${pathway}.tck | grep count
            done
        done
    done
done