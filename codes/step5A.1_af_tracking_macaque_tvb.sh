#!/bin/bash
#SBATCH --job-name=af_tracking_macaque_tvb
#SBATCH --output=log/af_tracking_macaque_tvb.%A_%a.out
#SBATCH --error=log/af_tracking_macaque_tvb.%A_%a.out
#SBATCH --partition=g3090
#SBATCH --gres=gpu:1
#SBATCH --array=0-7

NumofThreads=16

arr=(`cat /gpfs/userdata/yfwang/preprocess_fsl/macaque_tvb/macaque_tvb_list.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

datapath_fsl=/gpfs/userdata/yfwang/preprocess_fsl/macaque_tvb/${sub}
datapath_mrtrix=/gpfs/userdata/yfwang/preprocess_mrtrix/macaque_tvb/${sub}

protocolpath=/gpfs/userdata/yfwang/MarmosetWM/result/af_projection/protocol/macaque
# copy from af_projection/protocol

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/af_projection/macaque_tvb/${sub}

mkdir -p ${resultpath}

###############################################################
## register seed/target/exclude/stop mask into individual space
###############################################################
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

########################
## tracking using xtract
########################
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

#######################
## tracking using ifod2
#######################
mkdir -p ${resultpath}/ifod2
for tract in af_l af_r; do

    echo ${tract}
    mkdir -p ${resultpath}/ifod2/${tract}

    for angle in 30 45 60; do

        tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
               -seed_image ${resultpath}/masks/${tract}/seed.nii.gz \
               -include ${resultpath}/masks/${tract}/target1.nii.gz \
               -include ${resultpath}/masks/${tract}/target2.nii.gz \
               -mask ${datapath_mrtrix}/DTI/nodif_brain_mask.nii.gz \
               ${datapath_mrtrix}/FOD/wmfod.mif \
               ${resultpath}/ifod2/${tract}/${tract}_a${angle}_forward.tck \
               -force -nthreads $NumofThreads

        tckgen -stop -select 1k -angle ${angle} -maxlength 75 \
               -seed_image ${resultpath}/masks/${tract}/target1.nii.gz \
               -seed_image ${resultpath}/masks/${tract}/target2.nii.gz \
               -include ${resultpath}/masks/${tract}/seed.nii.gz \
               -mask ${datapath_mrtrix}/DTI/nodif_brain_mask.nii.gz \
               ${datapath_mrtrix}/FOD/wmfod.mif \
               ${resultpath}/ifod2/${tract}/${tract}_a${angle}_backward.tck \
               -force -nthreads $NumofThreads
    done

    tckedit ${resultpath}/ifod2/${tract}/${tract}_a30_forward.tck \
            ${resultpath}/ifod2/${tract}/${tract}_a45_forward.tck \
            ${resultpath}/ifod2/${tract}/${tract}_a60_forward.tck \
            ${resultpath}/ifod2/${tract}/${tract}_forward.tck \
            -force -nthread $NumofThreads

    tckedit ${resultpath}/ifod2/${tract}/${tract}_a30_backward.tck \
            ${resultpath}/ifod2/${tract}/${tract}_a45_backward.tck \
            ${resultpath}/ifod2/${tract}/${tract}_a60_backward.tck \
            ${resultpath}/ifod2/${tract}/${tract}_backward.tck \
            -force -nthread $NumofThreads

    tckmap ${resultpath}/ifod2/${tract}/${tract}_forward.tck \
           ${resultpath}/ifod2/${tract}/${tract}_forward.nii.gz \
           -template ${datapath_mrtrix}/FOD/wmfod.mif \
           -force -nthread $NumofThreads

    tckmap ${resultpath}/ifod2/${tract}/${tract}_backward.tck \
           ${resultpath}/ifod2/${tract}/${tract}_backward.nii.gz \
           -template ${datapath_mrtrix}/FOD/wmfod.mif \
           -force -nthread $NumofThreads

    # average across two running tracking
    fslmerge -t ${resultpath}/ifod2/${tract}/${tract}.nii.gz \
             ${resultpath}/ifod2/${tract}/${tract}_forward.nii.gz \
             ${resultpath}/ifod2/${tract}/${tract}_backward.nii.gz

    fslmaths ${resultpath}/ifod2/${tract}/${tract}.nii.gz \
             -Tmean ${resultpath}/ifod2/${tract}/${tract}.nii.gz

    fslmaths ${resultpath}/ifod2/${tract}/${tract}.nii.gz \
             -bin ${resultpath}/ifod2/${tract}/${tract}_bin.nii.gz

done

##############################
# individual atlas in b0 space
##############################
antsApplyTransforms -d 3 \
                    -i /n05dat/yfwang/user/Templates/MBNA_for_Publish/vol/MBNA__LR_304.nii.gz \
                    -o ${resultpath}/${sub}_BNA_in_b0.nii.gz \
                    -r ${datapath_fsl}/DTI/dti_FA.nii.gz \
                    -t [ ${datapath_fsl}/affine/ind2CIVM03mm/ind2CIVM03mm0GenericAffine.mat, 1 ] \
                    -t ${datapath_fsl}/affine/ind2CIVM03mm/ind2CIVM03mm1InverseWarp.nii.gz \
                    -n NearestNeighbor