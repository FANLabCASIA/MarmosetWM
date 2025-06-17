#!/bin/bash
#SBATCH --job-name=pbx_chimp
#SBATCH --output=log/pbx_chimp.%A_%a.out
#SBATCH --error=log/pbx_chimp.%A_%a.out
#SBATCH --partition=ga10
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --array=0-45%1

########
## chimp
########
datapath=/n05dat/yfwang/preprocess_fsl/chimp
resultpath=/n05dat/yfwang/user/MarmosetWM/result/af_projection/chimp
mkdir -p ${resultpath}

arr=(`cat ${datapath}/chimplist46.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

echo ${sub}

subdir=${resultpath}/${sub}
mkdir -p ${subdir}/xtract

for hemi in l r; do

    mkdir -p ${subdir}/xtract/af_${hemi}

    for roi in ROI_frontal ROI_parietal ROI_temporal exclude stop; do

        applywarp -i /n05dat/yfwang/user/MarmosetWM/result/af_projection/protocol/chimp/${roi}_${hemi}.nii.gz \
                  -o ${subdir}/xtract/af_${hemi}/${roi}.nii.gz \
                  -r ${datapath}/${sub}/DTI/nodif_brain.nii.gz \
                  -w ${datapath}/${sub}/xfms/HCP_warps_2_DTI.nii.gz \
                  --interp=nn
    done

    echo ${subdir}/xtract/af_${hemi}/ROI_frontal.nii.gz > ${subdir}/xtract/af_${hemi}/targets.txt
    echo ${subdir}/xtract/af_${hemi}/ROI_temporal.nii.gz >> ${subdir}/xtract/af_${hemi}/targets.txt

    ${FSLDIR}/bin/probtrackx2_gpu10.2 -s ${datapath}/${sub}/DTI.bedpostX/merged \
                                      -m ${datapath}/${sub}/DTI.bedpostX/nodif_brain_mask \
                                      -x ${subdir}/xtract/af_${hemi}/ROI_parietal.nii.gz \
                                      --waypoints=${subdir}/xtract/af_${hemi}/targets.txt \
                                      --avoid=${subdir}/xtract/af_${hemi}/exclude --nsamples=10000 \
                                      --stop=${subdir}/xtract/af_${hemi}/stop \
                                      -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 \
                                      -o density --dir=${subdir}/xtract/af_${hemi}
done

# individual atlas in b0 space
applywarp -i /n05dat/yfwang/user/MarmosetWM/support_data/atlas/chimp/atlas.nii.gz \
          -o ${subdir}/${sub}_BNA_in_b0.nii.gz \
          -r /n05dat/yfwang/preprocess_fsl/chimp/${sub}/DTI/nodif_brain.nii.gz \
          -w /n05dat/yfwang/preprocess_fsl/chimp/${sub}/xfms/HCP_warps_2_DTI.nii.gz \
          --interp=nn
