#!/bin/bash
#SBATCH --job-name=marmoset_xtract_post_brain_minds
#SBATCH --output=log/marmoset_xtract_post_brain_minds.%A_%a.out
#SBATCH --error=log/marmoset_xtract_post_brain_minds.%A_%a.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --array=0-44

datapath=/gpfs/userdata/yfwang/Data/marmoset_brain_minds_preprocessed/invivo
scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script
resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/xtract_result_brain_minds
supportdatapath=/gpfs/userdata/yfwang/MarmosetWM/support_data
recipespath=/gpfs/userdata/yfwang/MarmosetWM/result/protocols

arr=(`cat ${recipespath}/fiberlist.txt`)
fiber=${arr[$SLURM_ARRAY_TASK_ID]}

for thr in 0.005; do

    [ -f ${scriptpath}/group110_ori_${fiber}.sh ] && rm -rf ${scriptpath}/group110_ori_${fiber}.sh
    [ -f ${scriptpath}/group110_thr_${fiber}.sh ] && rm -rf ${scriptpath}/group110_thr_${fiber}.sh
    [ -f ${scriptpath}/group110_bin_${fiber}.sh ] && rm -rf ${scriptpath}/group110_bin_${fiber}.sh

    mkdir -p ${resultpath}/group110_tract/thr${thr}
    mkdir -p ${resultpath}/group110_tract/thr${thr}/bin_thr0.3
    cmd0="fslmerge -t ${resultpath}/group110_tract/thr${thr}/"

    cmd_ori="${cmd0}${fiber}_group110.nii.gz"
    cmd_thr="${cmd0}${fiber}_group110_${thr}.nii.gz"
    cmd_bin="${cmd0}${fiber}_group110_${thr}_bin.nii.gz"

    for sub in `cat ${supportdatapath}/marmoset_brain_minds_list.txt`; do

        subdir=${resultpath}/${sub}
        antsApplyTransforms -d 3 \
                            -i ${subdir}/xtract/tracts/${fiber}/densityNorm.nii.gz \
                            -o ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3.nii.gz \
                            -r ${supportdatapath}/template_DTI_FA_brain.nii.gz \
                            -t ${datapath}/${sub}/affine/ind2MBMv3/ind2MBMv31Warp.nii.gz \
                            -t ${datapath}/${sub}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat
        
        fslmaths ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3.nii.gz -thr ${thr} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}.nii.gz
        fslmaths ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}.nii.gz -bin ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}_bin.nii.gz

        cmd_ori="${cmd_ori} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3.nii.gz"
        cmd_thr="${cmd_thr} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}.nii.gz"
        cmd_bin="${cmd_bin} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}_bin.nii.gz"
        
    done

    echo ${cmd_ori} >> ${scriptpath}/group110_ori_${fiber}.sh
    echo ${cmd_thr} >> ${scriptpath}/group110_thr_${fiber}.sh
    echo ${cmd_bin} >> ${scriptpath}/group110_bin_${fiber}.sh

    bash ${scriptpath}/group110_ori_${fiber}.sh
    bash ${scriptpath}/group110_thr_${fiber}.sh
    bash ${scriptpath}/group110_bin_${fiber}.sh

    fslmaths ${resultpath}/group110_tract/thr${thr}/${fiber}_group110.nii.gz -Tmean ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_mean.nii.gz
    fslmaths ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_${thr}.nii.gz -Tmean ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_${thr}_mean.nii.gz
    fslmaths ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_${thr}_bin.nii.gz -Tmean ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_${thr}_bin_mean.nii.gz
    fslmaths ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_${thr}_bin_mean.nii.gz -thr 0.3 ${resultpath}/group110_tract/thr${thr}/bin_thr0.3/${fiber}_group110_${thr}_bin_mean_thr0.3.nii.gz

    rm ${scriptpath}/group110_ori_${fiber}.sh
    rm ${scriptpath}/group110_thr_${fiber}.sh
    rm ${scriptpath}/group110_bin_${fiber}.sh

done
