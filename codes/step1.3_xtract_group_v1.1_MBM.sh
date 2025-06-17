#!/bin/bash
#SBATCH --job-name=marmoset_xtract_post
#SBATCH --output=log/marmoset_xtract_post.%A_%a.out
#SBATCH --error=log/marmoset_xtract_post.%A_%a.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --exclude=n05,n15
#SBATCH --array=0-43

recipespath=/n02dat01/users/yfwang/MarmosetWM/result/protocols_v1.1

datapath=/n02dat01/users/yfwang/Data/marmoset_MBM
resultpath=/n02dat01/users/yfwang/MarmosetWM/result/xtract_result_v1.1_MBM

arr=(`cat ${recipespath}/fiberlist.txt`)
fiber=${arr[$SLURM_ARRAY_TASK_ID]}

for thr in 0.005 0.01; do

    rm /n02dat01/users/yfwang/MarmosetWM/script/group24_ori_${fiber}.sh
    rm /n02dat01/users/yfwang/MarmosetWM/script/group24_thr_${fiber}.sh
    rm /n02dat01/users/yfwang/MarmosetWM/script/group24_bin_${fiber}.sh

    mkdir -p ${resultpath}/group24_tract/thr${thr}
    mkdir -p ${resultpath}/group24_tract/thr${thr}/bin_thr0.3
    cmd0="fslmerge -t ${resultpath}/group24_tract/thr${thr}/"

    cmd_ori="${cmd0}${fiber}_group24.nii.gz"
    cmd_thr="${cmd0}${fiber}_group24_${thr}.nii.gz"
    cmd_bin="${cmd0}${fiber}_group24_${thr}_bin.nii.gz"

    for sub in `cat ${datapath}/marmoset_MBM_list.txt`; do

        subdir=${resultpath}/${sub}
        antsApplyTransforms -d 3 \
                            -i ${subdir}/xtract/tracts/${fiber}/densityNorm.nii.gz \
                            -o ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3.nii.gz \
                            -r /n02dat01/users/yfwang/MarmosetWM/support_data/template_DTI_FA_brain.nii.gz \
                            -t ${datapath}/${sub}/affine/ind2MBMv3/ind2MBMv31Warp.nii.gz \
                            -t ${datapath}/${sub}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat
        
        fslmaths ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3.nii.gz -thr ${thr} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}.nii.gz
        fslmaths ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}.nii.gz -bin ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}_bin.nii.gz

        cmd_ori="${cmd_ori} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3.nii.gz"
        cmd_thr="${cmd_thr} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}.nii.gz"
        cmd_bin="${cmd_bin} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}_bin.nii.gz"
        
    done

    echo ${cmd_ori} >> /n02dat01/users/yfwang/MarmosetWM/script/group24_ori_${fiber}.sh
    echo ${cmd_thr} >> /n02dat01/users/yfwang/MarmosetWM/script/group24_thr_${fiber}.sh
    echo ${cmd_bin} >> /n02dat01/users/yfwang/MarmosetWM/script/group24_bin_${fiber}.sh

    bash /n02dat01/users/yfwang/MarmosetWM/script/group24_ori_${fiber}.sh
    bash /n02dat01/users/yfwang/MarmosetWM/script/group24_thr_${fiber}.sh
    bash /n02dat01/users/yfwang/MarmosetWM/script/group24_bin_${fiber}.sh

    fslmaths ${resultpath}/group24_tract/thr${thr}/${fiber}_group24.nii.gz -Tmean ${resultpath}/group24_tract/thr${thr}/${fiber}_group24_mean.nii.gz
    fslmaths ${resultpath}/group24_tract/thr${thr}/${fiber}_group24_${thr}.nii.gz -Tmean ${resultpath}/group24_tract/thr${thr}/${fiber}_group24_${thr}_mean.nii.gz
    fslmaths ${resultpath}/group24_tract/thr${thr}/${fiber}_group24_${thr}_bin.nii.gz -Tmean ${resultpath}/group24_tract/thr${thr}/${fiber}_group24_${thr}_bin_mean.nii.gz
    fslmaths ${resultpath}/group24_tract/thr${thr}/${fiber}_group24_${thr}_bin_mean.nii.gz -thr 0.3 ${resultpath}/group24_tract/thr${thr}/bin_thr0.3/${fiber}_group24_${thr}_bin_mean_thr0.3.nii.gz

    rm /n02dat01/users/yfwang/MarmosetWM/script/group24_ori_${fiber}.sh
    rm /n02dat01/users/yfwang/MarmosetWM/script/group24_thr_${fiber}.sh
    rm /n02dat01/users/yfwang/MarmosetWM/script/group24_bin_${fiber}.sh

done
