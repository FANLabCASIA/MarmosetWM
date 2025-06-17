#!/bin/bash
#SBATCH --job-name=marmoset_anat_reg_fsl
#SBATCH --output=log/marmoset_anat_reg_fsl.%A_%a.out
#SBATCH --error=log/marmoset_anat_reg_fsl.%A_%a.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --exclude=n05,n15
#SBATCH --array=0-23

datapath=/n02dat01/users/yfwang/Data/marmoset_MBM

arr=(`cat ${datapath}/marmoset_MBM_list.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

subdir=${datapath}/${sub}

if [ ! -f ${subdir}/xfms/DTI_2_MBMv3.nii.gz ]; then

    rm -rf ${subdir}/xfms
    mkdir -p ${subdir}/xfms

    flirt -in ${subdir}/DTI/dti_FA.nii.gz \
          -ref /n02dat01/users/yfwang/MarmosetWM/support_data/template_DTI_FA_brain.nii.gz \
          -omat ${subdir}/xfms/DTI_2_MBMv3.mat


    fnirt --in=${subdir}/DTI/dti_FA.nii.gz \
          --ref=/n02dat01/users/yfwang/MarmosetWM/support_data/template_DTI_FA_brain.nii.gz \
          --aff=${subdir}/xfms/DTI_2_MBMv3.mat \
          --cout=${subdir}/xfms/DTI_2_MBMv3

fi

# # DTI <-> T2
# flirt -in ${subdir}/DTI/nodif_brain.nii.gz \
#       -ref ${subdir}/T2/${sub}_ses-01_T2w.nii.gz \
#       -omat ${subdir}/xfms/DTI_2_T2.mat

# convert_xfm -omat ${subdir}/xfms/T2_2_DTI.mat -inverse ${subdir}/xfms/DTI_2_T2.mat

# # DTI <-> MBMv3
# flirt -in ${subdir}/T2/${sub}_ses-01_T2w.nii.gz \
#       -ref /n02dat01/users/yfwang/MarmosetWM/support_data/template_T2w_brain.nii.gz \
#       -omat ${subdir}/xfms/T2_2_MBMv3.mat

# fnirt --in=${subdir}/T2/${sub}_ses-01_T2w.nii.gz \
#       --ref=/n02dat01/users/yfwang/MarmosetWM/support_data/template_T2w_brain.nii.gz \
#       --aff=${subdir}/xfms/T2_2_MBMv3.mat \
#       --cout=${subdir}/xfms/T2_2_MBMv3

# convertwarp --ref=/n02dat01/users/yfwang/MarmosetWM/support_data/template_T2w_brain.nii.gz \
#             --warp1=${subdir}/xfms/T2_2_MBMv3 \
#             --premat=${subdir}/xfms/DTI_2_T2.mat \
#             --out=${subdir}/xfms/DTI_2_MBMv3

# invwarp -w ${subdir}/xfms/DTI_2_MBMv3 -o ${subdir}/xfms/MBMv3_2_DTI -r ${subdir}/DTI/nodif_brain.nii.gz
