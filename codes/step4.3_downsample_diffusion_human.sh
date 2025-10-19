#!/bin/bash
#SBATCH --job-name=downsample_human
#SBATCH --output=downsample_human.%j.out
#SBATCH --error=downsample_human.%j.out
#SBATCH --partition=g3090
#SBATCH --gres=gpu:1

datapath=/n08d03/atlas_group/yfwang/Data/backup_human/MGH/allData
resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/hires_four_species

#############
## downsample
#############
mkdir -p ${resultpath}/human_downsampled
mkdir -p ${resultpath}/human_downsampled/DTI

3dresample -inset ${datapath}/DTI/data.nii.gz \
           -prefix ${resultpath}/human_downsampled/DTI/data.nii.gz \
           -dxyz 0.812 0.812 0.812

3dresample -inset ${datapath}/DTI/nodif_brain_mask.nii.gz \
           -prefix ${resultpath}/human_downsampled/DTI/nodif_brain_mask.nii.gz \
           -dxyz 0.812 0.812 0.812

cp ${datapath}/DTI/bvals ${resultpath}/human_downsampled/DTI
cp ${datapath}/DTI/bvecs ${resultpath}/human_downsampled/DTI

dtifit -k ${resultpath}/human_downsampled/DTI/data.nii.gz -o ${resultpath}/human_downsampled/DTI/dti -m ${resultpath}/human_downsampled/DTI/nodif_brain_mask.nii.gz -r ${resultpath}/human_downsampled/DTI/bvecs -b ${resultpath}/human_downsampled/DTI/bvals --save_tensor

3dresample -inset /n08d03/atlas_group/yfwang/Data/backup_human/MGH/DTI/allData_DTI_FA.nii.gz \
           -prefix ${resultpath}/human_downsampled/DTI/tmp/allData_DTI_FA.nii.gz \
           -dxyz 0.812 0.812 0.812

3dresample -inset /n08d03/atlas_group/yfwang/Data/backup_human/MGH/DTI/allData_DTI_V1.nii.gz \
           -prefix ${resultpath}/human_downsampled/DTI/tmp/allData_DTI_V1.nii.gz \
           -dxyz 0.812 0.812 0.812

${FSLDIR}/bin/bedpostx_gpu ${resultpath}/human_downsampled/DTI

#########
## xtract
#########
mkdir -p ${resultpath}/human_downsampled/xtract
mkdir -p ${resultpath}/human_downsampled/xtract/masks

for tract in af_l af_r; do

    mkdir -p ${resultpath}/human_downsampled/xtract/masks/${tract}
        
    3dresample -inset ${resultpath}/human/xtract/masks/${tract}/seed.nii.gz \
               -prefix ${resultpath}/human_downsampled/xtract/masks/${tract}/seed.nii.gz \
               -dxyz 0.812 0.812 0.812

    3dresample -inset ${resultpath}/human/xtract/masks/${tract}/target.nii.gz \
               -prefix ${resultpath}/human_downsampled/xtract/masks/${tract}/target.nii.gz \
               -dxyz 0.812 0.812 0.812

    3dresample -inset ${resultpath}/human/xtract/masks/${tract}/target1.nii.gz \
               -prefix ${resultpath}/human_downsampled/xtract/masks/${tract}/target1.nii.gz \
               -dxyz 0.812 0.812 0.812

    3dresample -inset ${resultpath}/human/xtract/masks/${tract}/exclude.nii.gz \
               -prefix ${resultpath}/human_downsampled/xtract/masks/${tract}/exclude.nii.gz \
               -dxyz 0.812 0.812 0.812

    echo ${resultpath}/human_downsampled/xtract/masks/${tract}/target1.nii.gz >> ${resultpath}/human_downsampled/xtract/masks/${tract}/target.txt
    echo ${resultpath}/human_downsampled/xtract/masks/${tract}/target.nii.gz >> ${resultpath}/human_downsampled/xtract/masks/${tract}/target.txt

    echo ${resultpath}/human_downsampled/xtract/masks/${tract}/target1.nii.gz >> ${resultpath}/human_downsampled/xtract/masks/${tract}/target_invert.txt
    echo ${resultpath}/human_downsampled/xtract/masks/${tract}/seed.nii.gz >> ${resultpath}/human_downsampled/xtract/masks/${tract}/target_invert.txt

done

ptxbin="$FSLDIR/bin/probtrackx2_gpu"

for tract in af_l af_r; do

    ${ptxbin} -s ${resultpath}/human_downsampled/DTI.bedpostX/merged \
              -m ${resultpath}/human_downsampled/DTI.bedpostX/nodif_brain_mask.nii.gz \
              --nsamples=5000 -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.2 -S 3200 \
              --seed=${resultpath}/human_downsampled/xtract/masks/${tract}/seed.nii.gz \
              --waypoints=${resultpath}/human_downsampled/xtract/masks/${tract}/target.txt \
              --avoid=${resultpath}/human_downsampled/xtract/masks/${tract}/exclude.nii.gz \
              -o density \
              --dir=${resultpath}/human_downsampled/xtract/tracts/${tract}

    ${ptxbin} -s ${resultpath}/human_downsampled/DTI.bedpostX/merged \
              -m ${resultpath}/human_downsampled/DTI.bedpostX/nodif_brain_mask.nii.gz \
              --nsamples=5000 -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.2 -S 3200 \
              --seed=${resultpath}/human_downsampled/xtract/masks/${tract}/target.nii.gz \
              --waypoints=${resultpath}/human_downsampled/xtract/masks/${tract}/target_invert.txt \
              --avoid=${resultpath}/human_downsampled/xtract/masks/${tract}/exclude.nii.gz \
              -o density \
              --dir=${resultpath}/human_downsampled/xtract/tracts/${tract}/tractsInv

    ${FSLDIR}/bin/fslmaths "${resultpath}/human_downsampled/xtract/tracts/${tract}/density" -add "${resultpath}/human_downsampled/xtract/tracts/${tract}/tractsInv/density" "${resultpath}/human_downsampled/xtract/tracts/${tract}/sum_density"
    echo "scale=5; `cat "${resultpath}/human_downsampled/xtract/tracts/${tract}/waytotal"` + `cat "${resultpath}/human_downsampled/xtract/tracts/${tract}/tractsInv/waytotal"` "|bc > "${resultpath}/human_downsampled/xtract/tracts/${tract}/sum_waytotal"
    ${FSLDIR}/bin/fslmaths "${resultpath}/human_downsampled/xtract/tracts/${tract}/sum_density" -div `cat "${resultpath}/human_downsampled/xtract/tracts/${tract}/sum_waytotal"` "${resultpath}/human_downsampled/xtract/tracts/${tract}/densityNorm"

done