#!/bin/bash
#SBATCH --job-name=marmoset_xtract_MBM
#SBATCH --output=log/marmoset_xtract_MBM.%A_%a.out
#SBATCH --error=log/marmoset_xtract_MBM.%A_%a.out
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --array=0-23%4

datapath=/gpfs/userdata/yfwang/Data/marmoset_MBM_preprocessed
resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/xtract_result_MBM
supportdatapath=/gpfs/userdata/yfwang/MarmosetWM/support_data
recipespath=/gpfs/userdata/yfwang/MarmosetWM/result/protocols

arr=(`cat ${supportdatapath}/marmoset_MBM_list.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

subdir=${resultpath}/${sub}
mkdir -p ${subdir}

cp ${datapath}/${sub}/DTI/nodif_brain.nii.gz ${subdir}

[ -d ${subdir}/xtract ] && rm -rf ${subdir}/xtract

./xtract_ants -bpx ${datapath}/${sub}/DTI.bedpostX \
              -out ${subdir}/xtract \
              -species CUSTOM \
              -str ${recipespath}/structureList \
              -p ${recipespath} \
              -ants ${datapath}/${sub}/affine/ind2MBMv3/ind2MBMv30GenericAffine.mat \
              -stdwarp  ${datapath}/${sub}/affine/ind2MBMv3/ind2MBMv31InverseWarp.nii.gz ${datapath}/${sub}/affine/ind2MBMv3/ind2MBMv31Warp.nii.gz \
              -pthr 0.1 \
              -stdref ${supportdatapath}/template_DTI_FA_brain.nii.gz \
              -native \
              -gpu
