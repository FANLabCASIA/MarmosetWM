#!/bin/bash
#SBATCH --job-name=marmoset_dorsal_allMBM
#SBATCH --output=marmoset_dorsal_allMBM.%A_%a.out
#SBATCH --error=marmoset_dorsal_allMBM.%A_%a.out
#SBATCH --partition=cpu
#SBATCH --array=0-23

path_200=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1
datapath=/gpfs/userdata/yfwang/Data/marmoset_MBM_preprocessed
resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/hires_tracking
supportdatapath=/gpfs/userdata/yfwang/MarmosetWM/support_data

arr=(`cat ${supportdatapath}/marmoset_MBM_list.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

NumofThreads=16

######################
## define ROI in MBMv3
######################
mkdir -p ${resultpath}/ROI_MBMv3

# Paxinos atlas: A45, AuCM, Tpt
fslmaths ${path_200}/atlas_MBM_cortex_vPaxinos.nii.gz -thr 31 -uthr 31 -bin ${resultpath}/ROI_MBMv3/Paxinos_A45.nii.gz
fslmaths ${path_200}/atlas_MBM_cortex_vPaxinos.nii.gz -thr 57 -uthr 57 -bin ${resultpath}/ROI_MBMv3/Paxinos_AuCM.nii.gz
fslmaths ${path_200}/atlas_MBM_cortex_vPaxinos.nii.gz -thr 124 -uthr 124 -bin ${resultpath}/ROI_MBMv3/Paxinos_Tpt.nii.gz 

for roi in A45 AuCM Tpt; do
    for hemi in left right; do
        fslmaths ${resultpath}/ROI_MBMv3/Paxinos_${roi}.nii.gz -mas ${path_200}/mask_brain_${hemi}.nii.gz ${resultpath}/ROI_MBMv3/Paxinos_${roi}_${hemi}.nii.gz
    done
done

###########
## tracking
###########
subdir=${resultpath}/dorsal_ifod2_allMBM/${sub}
mkdir -p ${subdir}

## define the ROI
mkdir -p ${subdir}/ROI

for roi in A45 AuCM Tpt; do
    for hemi in left right; do
        antsApplyTransforms -d 3 \
                            -i ${resultpath}/ROI_MBMv3/Paxinos_${roi}_${hemi}.nii.gz \
                            -o ${subdir}/ROI/Paxinos_${roi}_${hemi}.nii.gz \
                            -r ${datapath}/${sub}/DTI/dti_FA.nii.gz \
                            -t [ ${datapath}/${sub}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat, 1 ] \
                            -t ${datapath}/${sub}/affine/ind2MBMv3/ind2MBMv31InverseWarp.nii.gz \
                            -n NearestNeighbor
    done
done

for roi in dorsal ventral; do
    for hemi in left right; do
        antsApplyTransforms -d 3 \
                            -i ${resultpath}/ROI_MBMv3/mask_${roi}_${hemi}.nii.gz \
                            -o ${subdir}/ROI/mask_${roi}_${hemi}.nii.gz \
                            -r ${datapath}/${sub}/DTI/dti_FA.nii.gz \
                            -t [ ${datapath}/${sub}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat, 1 ] \
                            -t ${datapath}/${sub}/affine/ind2MBMv3/ind2MBMv31InverseWarp.nii.gz \
                            -n NearestNeighbor
    done
done

## tracking using ifod2 (Paxinos)
mkdir -p ${subdir}/ifod2

for ROI1 in A45; do
    for ROI2 in Tpt AuCM; do
        for hemi in left right; do

            mkdir -p ${subdir}/ifod2/${ROI1}_${ROI2}_${hemi}
            mkdir -p ${subdir}/ifod2/${ROI2}_${ROI1}_${hemi}

            for angle in 30 45 60; do
                tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
                       -seed_image ${subdir}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                       -include ${subdir}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                       -mask ${datapath}/${sub}/DTI.bedpostX/nodif_brain_mask.nii.gz \
                       ${datapath}/${sub}/FOD/wmfod.mif \
                       ${subdir}/ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_a${angle}_${hemi}.tck \
                       -force -nthreads $NumofThreads

                tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
                       -seed_image ${subdir}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                       -include ${subdir}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                       -mask ${datapath}/${sub}/DTI.bedpostX/nodif_brain_mask.nii.gz \
                       ${datapath}/${sub}/FOD/wmfod.mif \
                       ${subdir}/ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_a${angle}_${hemi}.tck \
                       -force -nthreads $NumofThreads
            done

            tckedit ${subdir}/ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_a30_${hemi}.tck \
                    ${subdir}/ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_a45_${hemi}.tck \
                    ${subdir}/ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_a60_${hemi}.tck \
                    ${subdir}/ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}.tck \
                    -force -nthread $NumofThreads

            tckedit ${subdir}/ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_a30_${hemi}.tck \
                    ${subdir}/ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_a45_${hemi}.tck \
                    ${subdir}/ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_a60_${hemi}.tck \
                    ${subdir}/ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}.tck \
                    -force -nthread $NumofThreads

            tckmap ${subdir}/ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}.tck \
                    ${subdir}/ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}.nii.gz \
                    -template ${datapath}/${sub}/FOD/wmfod.mif \
                    -force -nthread $NumofThreads

            tckmap ${subdir}/ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}.tck \
                    ${subdir}/ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}.nii.gz \
                    -template ${datapath}/${sub}/FOD/wmfod.mif \
                    -force -nthread $NumofThreads
        done
    done
done

for hemi in left right; do

    fslmerge -t ${subdir}/ifod2/A45_AuCM_${hemi}.nii.gz \
                ${subdir}/ifod2/A45_AuCM_${hemi}/A45_AuCM_${hemi}.nii.gz \
                ${subdir}/ifod2/AuCM_A45_${hemi}/AuCM_A45_${hemi}.nii.gz
    fslmaths ${subdir}/ifod2/A45_AuCM_${hemi}.nii.gz -Tmean ${subdir}/ifod2/A45_AuCM_${hemi}.nii.gz
    fslmaths ${subdir}/ifod2/A45_AuCM_${hemi}.nii.gz -bin ${subdir}/ifod2/A45_AuCM_${hemi}_bin.nii.gz

    fslmerge -t ${subdir}/ifod2/A45_Tpt_${hemi}.nii.gz \
                ${subdir}/ifod2/A45_Tpt_${hemi}/A45_Tpt_${hemi}.nii.gz \
                ${subdir}/ifod2/Tpt_A45_${hemi}/Tpt_A45_${hemi}.nii.gz
    fslmaths ${subdir}/ifod2/A45_Tpt_${hemi}.nii.gz -Tmean ${subdir}/ifod2/A45_Tpt_${hemi}.nii.gz
    fslmaths ${subdir}/ifod2/A45_Tpt_${hemi}.nii.gz -bin ${subdir}/ifod2/A45_Tpt_${hemi}_bin.nii.gz

done


## comare dorsal and ventral pathway
for ROI1 in A45; do
    for ROI2 in AuCM Tpt; do
        for hemi in left right; do
            for pathway in dorsal ventral; do

                echo ${ROI1} - ${ROI2} - ${hemi} - ${pathway}
                tckedit ${subdir}/ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}.tck \
                        -include ${subdir}/ROI/${pathway}_${hemi}.nii.gz \
                        ${subdir}/ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}_${pathway}.tck \
                        -force
                tckinfo ${subdir}/ifod2/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}_${pathway}.tck | grep count

                echo ${ROI2} - ${ROI1} - ${hemi} - ${pathway}
                tckedit ${subdir}/ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}.tck \
                        -include ${subdir}/ROI/${pathway}_${hemi}.nii.gz \
                        ${subdir}/ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}_${pathway}.tck \
                        -force
                tckinfo ${subdir}/ifod2/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}_${pathway}.tck | grep count
            done
        done
    done
done
