#!/bin/bash
#SBATCH --job-name=pbx_macaque_ucd
#SBATCH --output=log/pbx_macaque_ucd.%j.out
#SBATCH --error=log/pbx_macaque_ucd.%j.out
#SBATCH --partition=g3090
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --array=0-18

##########
## macaque
##########
datapath=/n05dat/yfwang/preprocess_fsl/macaque_ucd
resultpath=/n05dat/yfwang/user/MarmosetWM/result/af_projection/macaque_ucd
mkdir -p ${resultpath}

arr=(`cat ${datapath}/macaque_ucdavis_list.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

echo ${sub}

subdir=${resultpath}/${sub}
mkdir -p ${subdir}/xtract

# flirt T1 to DTI
mkdir -p ${subdir}/xfms
flirt -in ${subdir}/T1w_${sub}.nii.gz -ref ${datapath}/${sub}/DTI/nodif_brain.nii.gz -omat ${subdir}/xfms/T1_2_DTI.mat

for hemi in l r; do

    mkdir -p ${subdir}/xtract/af_${hemi}

    for roi in ROI_frontal ROI_parietal ROI_temporal exclude; do

        antsApplyTransforms -d 3 \
                            -i /n05dat/yfwang/user/MarmosetWM/result/af_projection/protocol/macaque/${roi}_${hemi}.nii.gz \
                            -o ${subdir}/xtract/af_${hemi}/${roi}.nii.gz \
                            -r ${subdir}/T1w_${sub}.nii.gz \
                            -t [ ${subdir}/affine/indi2NMT2asym0GenericAffine.mat, 1 ] \
                            -t ${subdir}/affine/indi2NMT2asym1InverseWarp.nii.gz \
                            -n NearestNeighbor

        flirt -in ${subdir}/xtract/af_${hemi}/${roi}.nii.gz \
              -ref ${datapath}/${sub}/DTI/nodif_brain.nii.gz \
              -applyxfm -init ${subdir}/xfms/T1_2_DTI.mat \
              -out ${subdir}/xtract/af_${hemi}/${roi}.nii.gz \
              -interp nearestneighbour
    done

    echo ${subdir}/xtract/af_${hemi}/ROI_frontal.nii.gz > ${subdir}/xtract/af_${hemi}/targets.txt
    echo ${subdir}/xtract/af_${hemi}/ROI_temporal.nii.gz >> ${subdir}/xtract/af_${hemi}/targets.txt

    ${FSLDIR}/bin/probtrackx2_gpu10.2 -s ${datapath}/${sub}/DTI.bedpostX/merged \
                                        -m ${datapath}/${sub}/DTI.bedpostX/nodif_brain_mask \
                                        -x ${subdir}/xtract/af_${hemi}/ROI_parietal.nii.gz \
                                        --waypoints=${subdir}/xtract/af_${hemi}/targets.txt \
                                        --avoid=${subdir}/xtract/af_${hemi}/exclude --nsamples=10000 \
                                        -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 \
                                        -o density --dir=${subdir}/xtract/af_${hemi}

done

# individual atlas in b0 space
antsApplyTransforms -d 3 \
                    -i /n05dat/yfwang/user/Templates/MBNA_for_Publish/vol/NMT2asym/MBNA_LR304_in_NMT2asym.nii.gz \
                    -o ${subdir}/${sub}_BNA_in_T1.nii.gz \
                    -r ${subdir}/T1w_${sub}.nii.gz \
                    -t [ ${subdir}/affine/indi2NMT2asym0GenericAffine.mat, 1 ] \
                    -t ${subdir}/affine/indi2NMT2asym1InverseWarp.nii.gz \
                    -n NearestNeighbor

flirt -in ${subdir}/${sub}_BNA_in_T1.nii.gz \
      -ref ${datapath}/${sub}/DTI/nodif_brain.nii.gz \
      -applyxfm -init ${subdir}/xfms/T1_2_DTI.mat \
      -out ${subdir}/${sub}_BNA_in_b0.nii.gz \
      -interp nearestneighbour
