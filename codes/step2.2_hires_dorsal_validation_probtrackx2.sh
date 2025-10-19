#!/bin/bash
#SBATCH --job-name=marmoset_hires_dorsal_pbx
#SBATCH --output=log/marmoset_hires_dorsal_pbx.%j.out
#SBATCH --error=log/marmoset_hires_dorsal_pbx.%j.out
#SBATCH --partition=ga10
#SBATCH --gres=gpu:1

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/hires_tracking

mkdir -p ${resultpath}/dorsal_probtrackx2

for ROI1 in A45; do
    for ROI2 in Tpt AuCM; do
        for hemi in left right; do

            mkdir -p ${resultpath}/dorsal_probtrackx2/${ROI1}_${ROI2}_${hemi}
            mkdir -p ${resultpath}/dorsal_probtrackx2/${ROI2}_${ROI1}_${hemi}

            ${FSLDIR}/bin/probtrackx2 -s ${resultpath}/DTI.bedpostX/merged \
                                      -m ${resultpath}/DTI.bedpostX/nodif_brain_mask \
                                      -x ${resultpath}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                                      --waypoints=${resultpath}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                                      --stop=${resultpath}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                                      --nsamples=5000 \
                                      -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.02 \
                                      -o density --dir=${resultpath}/dorsal_probtrackx2/${ROI1}_${ROI2}_${hemi}

            ${FSLDIR}/bin/probtrackx2 -s ${resultpath}/DTI.bedpostX/merged \
                                      -m ${resultpath}/DTI.bedpostX/nodif_brain_mask \
                                      -x ${resultpath}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                                      --waypoints=${resultpath}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                                      --stop=${resultpath}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                                      --nsamples=5000 \
                                      -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.02 \
                                      -o density --dir=${resultpath}/dorsal_probtrackx2/${ROI2}_${ROI1}_${hemi}

            # further tracking for comparing dorsal and ventral
            mask_dorsal=${resultpath}/ROI/mask_dorsal_${hemi}.nii.gz
            mask_dorsal=${resultpath}/ROI/mask_ventral_${hemi}.nii.gz

            mkdir -p ${resultpath}/dorsal_probtrackx2/${ROI1}_${ROI2}_${hemi}_dorsal
            mkdir -p ${resultpath}/dorsal_probtrackx2/${ROI1}_${ROI2}_${hemi}_ventral

            ${FSLDIR}/bin/probtrackx2 -s ${resultpath}/DTI.bedpostX/merged \
                                      -m ${resultpath}/DTI.bedpostX/nodif_brain_mask \
                                      -x ${resultpath}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                                      --waypoints=${mask_dorsal} \
                                      --targetmasks=${resultpath}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                                      --avoid=${mask_ventral} \
                                      --stop=${resultpath}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                                      --nsamples=1000 \
                                       -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.02 \
                                       -o density --dir=${resultpath}/dorsal_probtrackx2/${ROI1}_${ROI2}_${hemi}_dorsal
                                             
            ${FSLDIR}/bin/probtrackx2 -s ${resultpath}/DTI.bedpostX/merged \
                                      -m ${resultpath}/DTI.bedpostX/nodif_brain_mask \
                                      -x ${resultpath}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                                      --waypoints=${mask_ventral} \
                                      --targetmasks=${resultpath}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                                      --avoid=${mask_dorsal} \
                                      --stop=${resultpath}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                                      --nsamples=1000 \
                                      -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.02 \
                                      -o density --dir=${resultpath}/dorsal_probtrackx2/${ROI1}_${ROI2}_${hemi}_ventral

            mkdir -p ${resultpath}/dorsal_probtrackx2/${ROI2}_${ROI1}_${hemi}_dorsal
            mkdir -p ${resultpath}/dorsal_probtrackx2/${ROI2}_${ROI1}_${hemi}_ventral

            ${FSLDIR}/bin/probtrackx2 -s ${resultpath}/DTI.bedpostX/merged \
                                      -m ${resultpath}/DTI.bedpostX/nodif_brain_mask \
                                      -x ${resultpath}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                                      --waypoints=${mask_dorsal} \
                                      --targetmasks=${resultpath}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                                      --avoid=${mask_ventral} \
                                      --stop=${resultpath}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                                      --nsamples=1000 \
                                      -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.02 \
                                      -o density --dir=${resultpath}/dorsal_probtrackx2/${ROI2}_${ROI1}_${hemi}_dorsal
                                             
            ${FSLDIR}/bin/probtrackx2 -s ${resultpath}/DTI.bedpostX/merged \
                                      -m ${resultpath}/DTI.bedpostX/nodif_brain_mask \
                                      -x ${resultpath}/ROI/Paxinos_${ROI2}_${hemi}.nii.gz \
                                      --waypoints=${mask_ventral} \
                                      --targetmasks=${resultpath}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                                      --avoid=${mask_dorsal} \
                                      --stop=${resultpath}/ROI/Paxinos_${ROI1}_${hemi}.nii.gz \
                                      --nsamples=1000 \
                                      -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.02 \
                                      -o density --dir=${resultpath}/dorsal_probtrackx2/${ROI2}_${ROI1}_${hemi}_ventral
        done
    done
done

for hemi in left right; do

    fslmerge -t ${resultpath}/dorsal_probtrackx2/A45_AuCM_${hemi}.nii.gz \
             ${resultpath}/dorsal_probtrackx2/A45_AuCM_${hemi}/density.nii.gz \
             ${resultpath}/dorsal_probtrackx2/AuCM_A45_${hemi}/density.nii.gz
    fslmaths ${resultpath}/dorsal_probtrackx2/A45_AuCM_${hemi}.nii.gz -Tmean ${resultpath}/dorsal_probtrackx2/A45_AuCM_${hemi}.nii.gz
    fslmaths ${resultpath}/dorsal_probtrackx2/A45_AuCM_${hemi}.nii.gz -thr 10 -bin ${resultpath}/dorsal_probtrackx2/A45_AuCM_${hemi}_bin.nii.gz

    fslmerge -t ${resultpath}/dorsal_probtrackx2/A45_Tpt_${hemi}.nii.gz \
             ${resultpath}/dorsal_probtrackx2/A45_Tpt_${hemi}/density.nii.gz \
             ${resultpath}/dorsal_probtrackx2/Tpt_A45_${hemi}/density.nii.gz
    fslmaths ${resultpath}/dorsal_probtrackx2/A45_Tpt_${hemi}.nii.gz -Tmean ${resultpath}/dorsal_probtrackx2/A45_Tpt_${hemi}.nii.gz
    fslmaths ${resultpath}/dorsal_probtrackx2/A45_Tpt_${hemi}.nii.gz -thr 10 -bin ${resultpath}/dorsal_probtrackx2/A45_Tpt_${hemi}_bin.nii.gz

done