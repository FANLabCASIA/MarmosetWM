#!/bin/bash
#SBATCH --job-name=marmoset_high_res_bedpostx
#SBATCH --output=log/marmoset_high_res_bedpostx.%j.out
#SBATCH --error=log/marmoset_high_res_bedpostx.%j.out
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --nodelist=n19

# 80um
echo 80um
datapath=/n02dat01/users/yfwang/repo/marmoset_MBM/MBMv2/DMRI_80um_DWI_Preprocessed_TORTOISE
resultpath=/n02dat01/users/yfwang/Data/marmoset_80um/DTI
mkdir -p ${resultpath}

cp ${datapath}/data.nii.gz ${resultpath}
cp ${datapath}/mask.nii.gz ${resultpath}/nodif_brain_mask.nii.gz
cp ${datapath}/bvals ${resultpath}
cp ${datapath}/bvecs ${resultpath}

${FSLDIR}/bin/bedpostx_gpu ${resultpath}
