#!/bin/bash
#SBATCH --job-name=pbx_human
#SBATCH --output=log/pbx_human.%A_%a.out
#SBATCH --error=log/pbx_human.%A_%a.out
#SBATCH --partition=g3090
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --array=0-39

########
## human
########
datapath=/n05dat/yfwang/preprocess_fsl/human
resultpath=/n05dat/yfwang/user/MarmosetWM/result/af_projection/human
mkdir -p ${resultpath}

arr=(`cat ${datapath}/humanlist40.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

echo ${sub}

subdir=${resultpath}/${sub}
mkdir -p ${subdir}/xtract

for hemi in l r; do

    mkdir -p ${subdir}/xtract/af_${hemi}

    for roi in ROI_frontal ROI_parietal ROI_temporal exclude; do

        applywarp -i /n05dat/yfwang/user/MarmosetWM/result/af_projection/protocol/human/${roi}_${hemi}.nii.gz \
                  -o ${subdir}/xtract/af_${hemi}/${roi}.nii.gz \
                  -r /n07dat/OpenData/HCP1200/${sub}/T1w/Diffusion/nodif_brain_mask.nii.gz \
                  -w ${datapath}/${sub}/xfms/MNI_warps_2_DTI.nii.gz \
                  --interp=nn
    done

    echo ${subdir}/xtract/af_${hemi}/ROI_frontal.nii.gz > ${subdir}/xtract/af_${hemi}/targets.txt
    echo ${subdir}/xtract/af_${hemi}/ROI_temporal.nii.gz >> ${subdir}/xtract/af_${hemi}/targets.txt

    ${FSLDIR}/bin/probtrackx2_gpu10.2 -s /n07dat/OpenData/HCP1200/${sub}/T1w/Diffusion.bedpostX/merged \
                                        -m /n07dat/OpenData/HCP1200/${sub}/T1w/Diffusion.bedpostX/nodif_brain_mask \
                                        -x ${subdir}/xtract/af_${hemi}/ROI_parietal.nii.gz \
                                        --waypoints=${subdir}/xtract/af_${hemi}/targets.txt \
                                        --avoid=${subdir}/xtract/af_${hemi}/exclude --nsamples=10000 \
                                        -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 \
                                        -o density --dir=${subdir}/xtract/af_${hemi}

done

# individual atlas in b0 space
applywarp -i /n05dat/yfwang/user/Templates/BN_Atlas_246_1mm.nii.gz \
          -o ${resultpath}/human/${sub}_BNA_in_b0.nii.gz \
          -r /n07dat/OpenData/HCP1200/${sub}/T1w/Diffusion/nodif_brain_mask.nii.gz \
          -w /n05dat/yfwang/preprocess_fsl/human/${sub}/xfms/MNI_warps_2_DTI.nii.gz \
          --interp=nn
