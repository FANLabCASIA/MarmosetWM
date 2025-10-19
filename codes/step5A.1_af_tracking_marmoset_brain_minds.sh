#!/bin/bash
#SBATCH --job-name=af_tracking_marmoset
#SBATCH --output=log/af_tracking_marmoset.%A_%a.out
#SBATCH --error=log/af_tracking_marmoset.%A_%a.out
#SBATCH --partition=g3090
#SBATCH --gres=gpu:1
#SBATCH --array=0-109%4

NumofThreads=16

arr=(`cat /gpfs/userdata/yfwang/MarmosetWM/support_data/marmoset_brain_minds_list.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

datapath=/gpfs/userdata/yfwang/Data/marmoset_brain_minds/invivo/${sub}

protocolpath=/gpfs/userdata/yfwang/MarmosetWM/result/af_projection/protocol/marmoset
# copy from af_projection/protocol

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/af_projection/marmoset_brain_minds/${sub}

mkdir -p ${resultpath}

## register seed/target/exclude/stop mask into individual space
mkdir -p ${resultpath}/masks
for tract in af_l af_r; do

    echo ${tract}
    mkdir -p ${resultpath}/masks/${tract}

    for roi in seed target1 target2 exclude stop; do
        
        if [ -f ${protocolpath}/${tract}/${roi}.nii.gz ]; then
            antsApplyTransforms -d 3 \
                                -i ${protocolpath}/${tract}/${roi}.nii.gz \
                                -o ${resultpath}/masks/${tract}/${roi}.nii.gz \
                                -r ${datapath}/DTI/dti_FA.nii.gz \
                                -t [ ${datapath}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat, 1 ] \
                                -t ${datapath}/affine/ind2MBMv3/ind2MBMv31InverseWarp.nii.gz \
                                -n NearestNeighbor
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

    ${FSLDIR}/bin/probtrackx2_gpu10.2 -s ${datapath}/DTI.bedpostX/merged \
                                      -m ${datapath}/DTI.bedpostX/nodif_brain_mask \
                                      -x ${resultpath}/masks/${tract}/seed.nii.gz \
                                      --waypoints=${resultpath}/xtract/${tract}/targets.txt \
                                      --avoid=${resultpath}/masks/${tract}/exclude --nsamples=10000 \
                                      -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.125 \
                                      -o density --dir=${resultpath}/xtract/${tract}
done

##############################
# individual atlas in b0 space
##############################
antsApplyTransforms -d 3 \
                    -i /n05dat/yfwang/user/MarmosetWM/support_data/MBM_v3.0.1/atlas_MBM_cortex_vH.nii.gz \
                    -o ${resultpath}/${sub}_BNA_in_b0.nii.gz \
                    -r ${datapath}/DTI/dti_FA.nii.gz \
                    -t [ ${datapath}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat, 1 ] \
                    -t ${datapath}/affine/ind2MBMv3/ind2MBMv31InverseWarp.nii.gz \
                    -n NearestNeighbor