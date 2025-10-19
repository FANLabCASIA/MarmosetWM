#!/bin/bash
#SBATCH --job-name=af_tracking_macaque_ucd
#SBATCH --output=log/af_tracking_macaque_ucd.%A_%a.out
#SBATCH --error=log/af_tracking_macaque_ucd.%A_%a.out
#SBATCH --partition=g3090
#SBATCH --gres=gpu:1
#SBATCH --array=0-18

arr=(`cat /gpfs/userdata/yfwang/preprocess_fsl/macaque_ucd/macaque_ucdavis_list.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

datapath_fsl=/gpfs/userdata/yfwang/preprocess_fsl/macaque_ucd/${sub}

protocolpath=/gpfs/userdata/yfwang/MarmosetWM/result/af_projection/protocol/macaque
# copy from af_projection/protocol

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/af_projection/macaque_ucd/${sub}

mkdir -p ${resultpath}

## register seed/target/exclude/stop mask into individual space
mkdir -p ${resultpath}/masks
for tract in af_l af_r; do

    echo ${tract}
    mkdir -p ${resultpath}/masks/${tract}

    for roi in seed target1 target2 exclude stop; do
        
        if [ -f ${protocolpath}/${tract}/${roi}.nii.gz ]; then
            applywarp -i ${protocolpath}/${tract}/${roi}.nii.gz \
                      -o ${resultpath}/masks/${tract}/${roi}.nii.gz \
                      -r ${datapath_fsl}/DTI/nodif_brain.nii.gz \
                      -w ${datapath_fsl}/xfms/NMTv2_2_DTI_warpcoef.nii.gz \
                      --interp=nn
        fi
    done
done

## tracking using xtract
mkdir -p ${resultpath}/xtract
for tract in af_l af_r; do

    echo ${tract}
    mkdir -p ${resultpath}/xtract/${tract}

    echo ${resultpath}/masks/${tract}/target1.nii.gz > ${resultpath}/xtract/${tract}/targets.txt
    echo ${resultpath}/masks/${tract}/target2.nii.gz >> ${resultpath}/xtract/${tract}/targets.txt

    ${FSLDIR}/bin/probtrackx2_gpu10.2 -s ${datapath_fsl}/DTI.bedpostX/merged \
                                      -m ${datapath_fsl}/DTI.bedpostX/nodif_brain_mask \
                                      -x ${resultpath}/masks/${tract}/seed.nii.gz \
                                      --waypoints=${resultpath}/xtract/${tract}/targets.txt \
                                      --avoid=${resultpath}/masks/${tract}/exclude --nsamples=10000 \
                                      -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 \
                                      -o density --dir=${resultpath}/xtract/${tract}
done

##############################
# individual atlas in b0 space
##############################
antsApplyTransforms -d 3 \
                    -i /n05dat/yfwang/user/Templates/MBNA_for_Publish/vol/MBNA__LR_304.nii.gz \
                    -o ${resultpath}/${sub}_BNA_in_b0.nii.gz \
                    -r ${datapath_fsl}/DTI/nodif_brain.nii.gz \
                    -t [ ${datapath_fsl}/affine/ind2CIVM03mm/ind2CIVM03mm0GenericAffine.mat, 1 ] \
                    -t ${datapath_fsl}/affine/ind2CIVM03mm/ind2CIVM03mm1InverseWarp.nii.gz \
                    -n NearestNeighbor

# antsApplyTransforms -d 3 \
#                     -i /n05dat/yfwang/user/Templates/MBNA_for_Publish/vol/NMT2asym/MBNA_LR304_in_NMT2asym.nii.gz \
#                     -o ${resultpath}/${sub}_BNA_in_T1.nii.gz \
#                     -r ${datapath_fsl}/T1w_acpc_dc_restore.nii.gz \
#                     -t [ ${datapath_fsl}/affine/indi2NMT2asym0GenericAffine.mat, 1 ] \
#                     -t ${datapath_fsl}/affine/indi2NMT2asym1InverseWarp.nii.gz \
#                     -n NearestNeighbor

# flirt -in ${resultpath}/${sub}_BNA_in_T1.nii.gz \
#       -ref ${datapath_fsl}/DTI/nodif_brain.nii.gz \
#       -applyxfm -init ${datapath_fsl}/xfms/T1_2_DTI.mat \
#       -out ${resultpath}/${sub}_BNA_in_b0.nii.gz \
#       -interp nearestneighbour