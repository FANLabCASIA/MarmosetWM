#!/bin/bash
#SBATCH -J preprocess_MGH
#SBATCH -o log/preprocess_MGH.%j.out
#SBATCH -e log/preprocess_MGH.%j.out
#SBATCH -p gpu
#SBATCH --gres=gpu:1

datapath=/n08d03/atlas_group/yfwang/Data/backup_human/MGH

dtifit -k ${datapath}/allData/DTI/data.nii.gz -o ${datapath}/allData/DTI/dti -m ${datapath}/allData/DTI/nodif_brain_mask.nii.gz -r ${datapath}/allData/DTI/bvecs -b ${datapath}/allData/DTI/bvals

${FSLDIR}/bin/bedpostx_gpu ${datapath}/allData/DTI
