#!/bin/bash
#SBATCH -J bed
#SBATCH -o bed.%j.out
#SBATCH -e bed.%j.out
#SBATCH -p gpu
#SBATCH --nodelist=n19
#SBATCH --gres=gpu:1

datapath=/gpfs/userdata/yfwang/Data/chimp_ecb

${FSLDIR}/bin/bedpostx_gpu ${datapath}/DTI

# mkdir -p ${datapath}/xfms

# flirt -in ${datapath}/DTI/nodif_brain.nii.gz -ref ${datapath}/anat/flash_contr1_warp.nii.gz -omat ${datapath}/xfms/DTI_2_T1.mat
# convert_xfm -omat ${datapath}/xfms/T1_2_DTI.mat -inverse ${datapath}/xfms/DTI_2_T1.mat

# flirt -in ${datapath}/anat/flash_contr1_warp.nii.gz -ref /n02dat01/users/yfwang/Data/Chimp/ChimpYerkes29_T1w_0.8mm_brain.nii.gz -omat ${datapath}/xfms/T1_2_Yerkes.mat
# fnirt --in=${datapath}/anat/flash_contr1_warp.nii.gz --ref=/n02dat01/users/yfwang/Data/Chimp/ChimpYerkes29_T1w_0.8mm_brain.nii.gz --aff=${datapath}/xfms/T1_2_Yerkes.mat --cout=${datapath}/xfms/T1_2_Yerkes

convertwarp --ref=/n02dat01/users/yfwang/Data/Chimp/ChimpYerkes29_T1w_0.8mm_brain.nii.gz \
            --warp1=${datapath}/xfms/T1_2_Yerkes \
            --premat=${datapath}/xfms/DTI_2_T1.mat \
            --out=${datapath}/xfms/DTI_2_Yerkes

invwarp -w ${datapath}/xfms/DTI_2_Yerkes -o ${datapath}/xfms/Yerkes_2_DTI -r ${datapath}/DTI/nodif_brain.nii.gz

applywarp -i /n02dat01/users/yfwang/Data/Chimp/ChimpYerkes29_T1w_0.8mm_brain.nii.gz -o ${datapath}/xfms/Yerkes_in_b0.nii.gz -r ${datapath}/DTI/nodif_brain.nii.gz -w ${datapath}/xfms/Yerkes_2_DTI.nii.gz

