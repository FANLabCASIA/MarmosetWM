#!/bin/bash
#SBATCH --job-name=pbx_marmoset_minds
#SBATCH --output=log/pbx_marmoset_minds.%A_%a.out
#SBATCH --error=log/pbx_marmoset_minds.%A_%a.out
#SBATCH --partition=g3090
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --array=1-109

###########
## marmoset
###########
datapath=/n05dat/yfwang/backup_marmoset/marmoset_brain_minds
resultpath=/n05dat/yfwang/user/MarmosetWM/result/af_projection/marmoset_minds
mkdir -p ${resultpath}

arr=(`cat ${datapath}/list_t1_dwi_aging.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

echo ${sub}

subdir=${resultpath}/${sub}
mkdir -p ${subdir}/xtract

for hemi in l r; do

    mkdir -p ${subdir}/xtract/af_${hemi}

    for roi in ROI_frontal ROI_parietal ROI_temporal exclude; do

        antsApplyTransforms -d 3 \
                            -i /n05dat/yfwang/user/MarmosetWM/result/af_projection/protocol/marmoset/${roi}_${hemi}.nii.gz \
                            -o ${subdir}/xtract/af_${hemi}/${roi}.nii.gz \
                            -r ${datapath}/invivo/${sub}/DTI/dti_FA.nii.gz \
                            -t [ ${datapath}/invivo/${sub}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat, 1 ] \
                            -t ${datapath}/invivo/${sub}/affine/ind2MBMv3/ind2MBMv31InverseWarp.nii.gz \
                            -n NearestNeighbor

    done

    echo ${subdir}/xtract/af_${hemi}/ROI_frontal.nii.gz > ${subdir}/xtract/af_${hemi}/targets.txt
    echo ${subdir}/xtract/af_${hemi}/ROI_temporal.nii.gz >> ${subdir}/xtract/af_${hemi}/targets.txt

    ${FSLDIR}/bin/probtrackx2_gpu10.2 -s ${datapath}/invivo/${sub}/DTI.bedpostX/merged \
                                      -m ${datapath}/invivo/${sub}/DTI.bedpostX/nodif_brain_mask \
                                      -x ${subdir}/xtract/af_${hemi}/ROI_parietal.nii.gz \
                                      --waypoints=${subdir}/xtract/af_${hemi}/targets.txt \
                                      --avoid=${subdir}/xtract/af_${hemi}/exclude --nsamples=10000 \
                                      -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.125 \
                                      -o density --dir=${subdir}/xtract/af_${hemi}

done

antsApplyTransforms -d 3 \
                    -i /n05dat/yfwang/user/MarmosetWM/support_data/MBM_v3.0.1/atlas_MBM_cortex_vH.nii.gz \
                    -o ${subdir}/${sub}_BNA_in_b0.nii.gz \
                    -r ${datapath}/invivo/${sub}/DTI/dti_FA.nii.gz \
                    -t [ ${datapath}/invivo/${sub}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat, 1 ] \
                    -t ${datapath}/invivo/${sub}/affine/ind2MBMv3/ind2MBMv31InverseWarp.nii.gz \
                    -n NearestNeighbor
