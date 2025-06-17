#!/bin/bash
#SBATCH --job-name=marmoset_xtract_group
#SBATCH --output=log/marmoset_xtract_group.%A_%a.out
#SBATCH --error=log/marmoset_xtract_group.%A_%a.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --exclude=n05,n15,n06
#SBATCH --array=0-44

recipespath=/n02dat01/users/yfwang/MarmosetWM/result/protocols_v1.1

datapath=/n02dat01/users/yfwang/Data/marmoset_brain_minds
resultpath=/n02dat01/users/yfwang/MarmosetWM/result/xtract_result_v1.1_minds

arr=(`cat ${recipespath}/fiberlist.txt`)
fiber=${arr[$SLURM_ARRAY_TASK_ID]}

for thr in 0.005 0.01; do

    rm /n02dat01/users/yfwang/MarmosetWM/script/group110_ori_${fiber}.sh
    rm /n02dat01/users/yfwang/MarmosetWM/script/group110_thr_${fiber}.sh
    rm /n02dat01/users/yfwang/MarmosetWM/script/group110_bin_${fiber}.sh

    mkdir -p ${resultpath}/group110_tract/thr${thr}
    mkdir -p ${resultpath}/group110_tract/thr${thr}/bin_thr0.3
    cmd0="fslmerge -t ${resultpath}/group110_tract/thr${thr}/"

    cmd_ori="${cmd0}${fiber}_group110.nii.gz"
    cmd_thr="${cmd0}${fiber}_group110_${thr}.nii.gz"
    cmd_bin="${cmd0}${fiber}_group110_${thr}_bin.nii.gz"

    for sub in `cat ${datapath}/list_t1_dwi_aging.txt`; do

        subdir=${resultpath}/${sub}
        antsApplyTransforms -d 3 \
                            -i ${subdir}/xtract/tracts/${fiber}/densityNorm.nii.gz \
                            -o ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3.nii.gz \
                            -r /n02dat01/users/yfwang/MarmosetWM/support_data/template_DTI_FA_brain.nii.gz \
                            -t ${datapath}/invivo/${sub}/affine/ind2MBMv3/ind2MBMv31Warp.nii.gz \
                            -t ${datapath}/invivo/${sub}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat
        
        fslmaths ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3.nii.gz -thr ${thr} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}.nii.gz
        fslmaths ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}.nii.gz -bin ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}_bin.nii.gz

        cmd_ori="${cmd_ori} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3.nii.gz"
        cmd_thr="${cmd_thr} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}.nii.gz"
        cmd_bin="${cmd_bin} ${subdir}/xtract/tracts/${fiber}/densityNorm_MBMv3_${thr}_bin.nii.gz"
        
    done

    echo ${cmd_ori} >> /n02dat01/users/yfwang/MarmosetWM/script/group110_ori_${fiber}.sh
    echo ${cmd_thr} >> /n02dat01/users/yfwang/MarmosetWM/script/group110_thr_${fiber}.sh
    echo ${cmd_bin} >> /n02dat01/users/yfwang/MarmosetWM/script/group110_bin_${fiber}.sh

    bash /n02dat01/users/yfwang/MarmosetWM/script/group110_ori_${fiber}.sh
    bash /n02dat01/users/yfwang/MarmosetWM/script/group110_thr_${fiber}.sh
    bash /n02dat01/users/yfwang/MarmosetWM/script/group110_bin_${fiber}.sh

    fslmaths ${resultpath}/group110_tract/thr${thr}/${fiber}_group110.nii.gz -Tmean ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_mean.nii.gz
    fslmaths ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_${thr}.nii.gz -Tmean ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_${thr}_mean.nii.gz
    fslmaths ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_${thr}_bin.nii.gz -Tmean ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_${thr}_bin_mean.nii.gz
    fslmaths ${resultpath}/group110_tract/thr${thr}/${fiber}_group110_${thr}_bin_mean.nii.gz -thr 0.3 ${resultpath}/group110_tract/thr${thr}/bin_thr0.3/${fiber}_group110_${thr}_bin_mean_thr0.3.nii.gz

    rm /n02dat01/users/yfwang/MarmosetWM/script/group110_ori_${fiber}.sh
    rm /n02dat01/users/yfwang/MarmosetWM/script/group110_thr_${fiber}.sh
    rm /n02dat01/users/yfwang/MarmosetWM/script/group110_bin_${fiber}.sh

done

# fslmaths af_l_group110_0.005_bin_mean_thr0.3.nii.gz -add af_r_group110_0.005_bin_mean_thr0.3.nii.gz af_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths ar_l_group110_0.005_bin_mean_thr0.3.nii.gz -add ar_r_group110_0.005_bin_mean_thr0.3.nii.gz ar_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths atr_l_group110_0.005_bin_mean_thr0.3.nii.gz -add atr_r_group110_0.005_bin_mean_thr0.3.nii.gz atr_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths cbd_l_group110_0.005_bin_mean_thr0.3.nii.gz -add cbd_r_group110_0.005_bin_mean_thr0.3.nii.gz cbd_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths cbp_l_group110_0.005_bin_mean_thr0.3.nii.gz -add cbp_r_group110_0.005_bin_mean_thr0.3.nii.gz cbp_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths cbt_l_group110_0.005_bin_mean_thr0.3.nii.gz -add cbt_r_group110_0.005_bin_mean_thr0.3.nii.gz cbt_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths cst_l_group110_0.005_bin_mean_thr0.3.nii.gz -add cst_r_group110_0.005_bin_mean_thr0.3.nii.gz cst_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths fa_l_group110_0.005_bin_mean_thr0.3.nii.gz -add fa_r_group110_0.005_bin_mean_thr0.3.nii.gz fa_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths fx_l_group110_0.005_bin_mean_thr0.3.nii.gz -add fx_r_group110_0.005_bin_mean_thr0.3.nii.gz fx_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths ifo_l_group110_0.005_bin_mean_thr0.3.nii.gz -add ifo_r_group110_0.005_bin_mean_thr0.3.nii.gz ifo_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths ilf_l_group110_0.005_bin_mean_thr0.3.nii.gz -add ilf_r_group110_0.005_bin_mean_thr0.3.nii.gz ilf_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths mdlf_l_group110_0.005_bin_mean_thr0.3.nii.gz -add mdlf_r_group110_0.005_bin_mean_thr0.3.nii.gz mdlf_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths or_l_group110_0.005_bin_mean_thr0.3.nii.gz -add or_r_group110_0.005_bin_mean_thr0.3.nii.gz or_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths ptr_l_group110_0.005_bin_mean_thr0.3.nii.gz -add ptr_r_group110_0.005_bin_mean_thr0.3.nii.gz ptr_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths slf1_l_group110_0.005_bin_mean_thr0.3.nii.gz -add slf1_r_group110_0.005_bin_mean_thr0.3.nii.gz slf1_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths slf2_l_group110_0.005_bin_mean_thr0.3.nii.gz -add slf2_r_group110_0.005_bin_mean_thr0.3.nii.gz slf2_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths slf3_l_group110_0.005_bin_mean_thr0.3.nii.gz -add slf3_r_group110_0.005_bin_mean_thr0.3.nii.gz slf3_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths str_l_group110_0.005_bin_mean_thr0.3.nii.gz -add str_r_group110_0.005_bin_mean_thr0.3.nii.gz str_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths unc_l_group110_0.005_bin_mean_thr0.3.nii.gz -add unc_r_group110_0.005_bin_mean_thr0.3.nii.gz unc_group110_0.005_bin_mean_thr0.3.nii.gz
# fslmaths vof_l_group110_0.005_bin_mean_thr0.3.nii.gz -add vof_r_group110_0.005_bin_mean_thr0.3.nii.gz vof_group110_0.005_bin_mean_thr0.3.nii.gz

