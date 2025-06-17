#!/bin/bash
#SBATCH --job-name=pbx_macaque
#SBATCH --output=log/pbx_macaque.%j.out
#SBATCH --error=log/pbx_macaque.%j.out
#SBATCH --partition=g3090
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --array=0-7

##########
## macaque
##########
datapath=/n05dat/yfwang/preprocess_fsl/macaque_tvb
resultpath=/n05dat/yfwang/user/MarmosetWM/result/af_projection/macaque_tvb
mkdir -p ${resultpath}

arr=(`cat ${datapath}/macaque_tvb_list.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

echo ${sub}

subdir=${resultpath}/${sub}
mkdir -p ${subdir}/xtract

for hemi in l r; do

    mkdir -p ${subdir}/xtract/af_${hemi}

    for roi in ROI_frontal ROI_parietal ROI_temporal exclude; do

        applywarp -i /n05dat/yfwang/user/MarmosetWM/result/af_projection/protocol/macaque/${roi}_${hemi}.nii.gz \
                  -o ${subdir}/xtract/af_${hemi}/${roi}.nii.gz \
                  -r ${datapath}/${sub}/DTI/nodif_brain.nii.gz \
                  -w ${datapath}/${sub}/xfms/NMTv2_2_DTI_warpcoef.nii.gz \
                  --interp=nn
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
                    -i /n05dat/yfwang/user/Templates/MBNA_for_Publish/vol/MBNA__LR_304.nii.gz \
                    -o ${subdir}/${sub}_BNA_in_b0.nii.gz \
                    -r /n05dat/yfwang/preprocess_fsl/macaque_tvb/${sub}/DTI/dti_FA.nii.gz \
                    -t [/n05dat/yfwang/preprocess_fsl/macaque_tvb/${sub}/affine/ind2CIVM03mm/ind2CIVM03mm0GenericAffine.mat, 1] \
                    -t /n05dat/yfwang/preprocess_fsl/macaque_tvb/${sub}/affine/ind2CIVM03mm/ind2CIVM03mm1InverseWarp.nii.gz \
                    -n NearestNeighbor
