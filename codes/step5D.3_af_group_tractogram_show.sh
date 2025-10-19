#!/bin/bash

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/af_group_tractogram

tract=af_l

########
## human
########
mkdir -p ${resultpath}/human

thr1=0.005
thr2=0.001

cmd="fslmerge -t ${resultpath}/human/${tract}_human40_thr${thr1}.nii.gz"

for sub in `cat /gpfs/userdata/yfwang/preprocess_fsl/human/humanlist40.txt`; do

    subdir=/gpfs/userdata/yfwang/preprocess_fsl/human/${sub}
    applywarp -i ${subdir}/xtract/tracts/${tract}/densityNorm.nii.gz \
              -o ${resultpath}/human/${sub}_${tract}_densityNorm_MNI152.nii.gz \
              -r /gpfs/userdata/yfwang/preprocess_fsl/human/MNI152_T1_1mm_brain.nii.gz \
              -w ${subdir}/xfms/DTI_warps_2_MNI.nii.gz \
              --interp=nn

    fslmaths ${resultpath}/human/${sub}_${tract}_densityNorm_MNI152.nii.gz \
             -thr ${thr1} \
             ${resultpath}/human/${sub}_${tract}_densityNorm_MNI152_${thr1}.nii.gz

    cmd="${cmd} ${resultpath}/human/${sub}_${tract}_densityNorm_MNI152_${thr1}.nii.gz"
done

echo ${cmd} >> ${resultpath}/human_${tract}.sh
bash ${resultpath}/human_${tract}.sh
rm ${resultpath}/human_${tract}.sh

fslmaths ${resultpath}/human/${tract}_human40_thr${thr1}.nii.gz -Tmean ${resultpath}/human/${tract}_human40_thr${thr1}_mean.nii.gz
fslmaths ${resultpath}/human/${tract}_human40_thr${thr1}_mean.nii.gz -thr ${thr2} ${resultpath}/human/${tract}_human40_thr${thr1}_mean_thr${thr2}.nii.gz
fslmaths ${resultpath}/human/${tract}_human40_thr${thr1}_mean_thr${thr2}.nii.gz -bin ${resultpath}/human/${tract}_human40_thr${thr1}_mean_thr${thr2}_bin.nii.gz

########
## chimp
########
mkdir -p ${resultpath}/chimp

cmd="fslmerge -t ${resultpath}/chimp/${tract}_chimp46.nii.gz"

for sub in `cat /gpfs/userdata/yfwang/preprocess_fsl/chimp/chimplist46.txt`; do

    subdir=/gpfs/userdata/yfwang/preprocess_fsl/chimp/${sub}

    applywarp -i /gpfs/userdata/yfwang/MarmosetWM/result/af_projection/chimp/${sub}/xtract/${tract}/density.nii.gz \
              -o ${resultpath}/chimp/${sub}_densityNorm_Yerkes29.nii.gz \
              -r /gpfs/userdata/yfwang/Data/Chimp/ChimpYerkes29_T1w_0.8mm_brain.nii.gz \
              -w /gpfs/userdata/yfwang/preprocess_fsl/chimp/${sub}/xfms/DTI_warps_2_HCP.nii.gz \
              --interp=nn

    cmd="${cmd} ${resultpath}/chimp/${sub}_${tract}_densityNorm_Yerkes29.nii.gz"
done

echo ${cmd} >> ${resultpath}/chimp_${tract}.sh
bash ${resultpath}/chimp_${tract}.sh
rm ${resultpath}/chimp_${tract}.sh

fslmaths ${resultpath}/chimp/${tract}_chimp46.nii.gz -Tmean ${resultpath}/chimp/${tract}_chimp46_mean.nii.gz

##########
## macaque
##########
mkdir -p ${resultpath}/macaque

cmd="fslmerge -t ${resultpath}/macaque/${tract}_macaque8.nii.gz"

for sub in `cat /gpfs/userdata/yfwang/preprocess_fsl/macaque_tvb/macaque_tvb_list.txt`; do

    subdir=/gpfs/userdata/yfwang/preprocess_fsl/macaque_tvb/${sub}
    applywarp -i /gpfs/userdata/yfwang/MarmosetWM/result/af_projection/macaque_tvb/${sub}/xtract/${tract}/density.nii.gz \
              -o ${resultpath}/macaque/${sub}_densityNorm_NMT.nii.gz \
              -r /n05dat/yfwang/user/Templates/NMT_v2.0_asym/NMT_v2.0_asym/NMT_v2.0_asym_SS.nii.gz \
              -w ${subdir}/xfms/DTI_2_NMTv2_warpcoef.nii.gz \
              --interp=nn

    cmd="${cmd} ${resultpath}/macaque/${sub}_${tract}_densityNorm_NMT.nii.gz"
done

echo ${cmd} >> ${resultpath}/macaque_${tract}.sh
bash ${resultpath}/macaque_${tract}.sh
rm ${resultpath}/macaque_${tract}.sh

fslmaths ${resultpath}/macaque/${tract}_macaque8.nii.gz -Tmean ${resultpath}/macaque/${tract}_macaque8_mean.nii.gz
fslmaths ${resultpath}/macaque/${tract}_macaque8_mean.nii.gz -thr 2 -bin ${resultpath}/macaque/${tract}_macaque8_mean_thr2_bin.nii.gz

###########
## marmoset
###########
mkdir -p ${resultpath}/marmoset

cp /gpfs/userdata/yfwang/MarmosetWM/result/xtract_result_MBM/group24_tract/thr0.005/${tract}_group24_0.005_mean.nii.gz ${resultpath}/marmoset
fslmaths ${resultpath}/marmoset/${tract}_group24_0.005_mean.nii.gz -bin ${resultpath}/marmoset/${tract}_group24_0.005_mean_bin.nii.gz
