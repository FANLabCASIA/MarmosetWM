#!/bin/bash
#SBATCH --job-name=downsample_macaque
#SBATCH --output=downsample_macaque.%j.out
#SBATCH --error=downsample_macaque.%j.out
#SBATCH --partition=g3090
#SBATCH --gres=gpu:1

datapath=/gpfs/userdata/yfwang/Data/Duke_Macaque_DTI/m30
resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/hires_four_species

#############
## downsample
#############
mkdir -p ${resultpath}/macaque_downsampled
mkdir -p ${resultpath}/macaque_downsampled/DTI

3dresample -inset ${datapath}/DTI/data.nii.gz \
           -prefix ${resultpath}/macaque_downsampled/DTI/data.nii.gz \
           -dxyz 0.284 0.284 0.284

3dresample -inset ${datapath}/DTI/nodif_brain_mask.nii.gz \
           -prefix ${resultpath}/macaque_downsampled/DTI/nodif_brain_mask.nii.gz \
           -dxyz 0.284 0.284 0.284

cp ${datapath}/DTI/bvals ${resultpath}/macaque_downsampled/DTI
cp ${datapath}/DTI/bvecs ${resultpath}/macaque_downsampled/DTI

dtifit -k ${resultpath}/macaque_downsampled/DTI/data.nii.gz -o ${resultpath}/macaque_downsampled/DTI/dti -m ${resultpath}/macaque_downsampled/DTI/nodif_brain_mask.nii.gz -r ${resultpath}/macaque_downsampled/DTI/bvecs -b ${resultpath}/macaque_downsampled/DTI/bvals --save_tensor

${FSLDIR}/bin/bedpostx_gpu ${resultpath}/macaque_downsampled/DTI

#########
## xtract
#########
mkdir -p ${resultpath}/macaque_downsampled/xtract
mkdir -p ${resultpath}/macaque_downsampled/xtract/masks

for tract in af_l af_r; do

    mkdir -p ${resultpath}/macaque_downsampled/xtract/masks/${tract}
        
    3dresample -inset ${resultpath}/macaque/xtract/masks/${tract}/seed.nii.gz \
               -prefix ${resultpath}/macaque_downsampled/xtract/masks/${tract}/seed.nii.gz \
               -dxyz 0.284 0.284 0.284

    3dresample -inset ${resultpath}/macaque/xtract/masks/${tract}/target.nii.gz \
               -prefix ${resultpath}/macaque_downsampled/xtract/masks/${tract}/target.nii.gz \
               -dxyz 0.284 0.284 0.284

    3dresample -inset ${resultpath}/macaque/xtract/masks/${tract}/target1.nii.gz \
               -prefix ${resultpath}/macaque_downsampled/xtract/masks/${tract}/target1.nii.gz \
               -dxyz 0.284 0.284 0.284

    3dresample -inset ${resultpath}/macaque/xtract/masks/${tract}/exclude.nii.gz \
               -prefix ${resultpath}/macaque_downsampled/xtract/masks/${tract}/exclude.nii.gz \
               -dxyz 0.284 0.284 0.284

    3dresample -inset ${resultpath}/macaque/xtract/masks/${tract}/stop.nii.gz \
               -prefix ${resultpath}/macaque_downsampled/xtract/masks/${tract}/stop.nii.gz \
               -dxyz 0.284 0.284 0.284

    echo ${resultpath}/macaque_downsampled/xtract/masks/${tract}/target1.nii.gz >> ${resultpath}/macaque_downsampled/xtract/masks/${tract}/target.txt
    echo ${resultpath}/macaque_downsampled/xtract/masks/${tract}/target.nii.gz >> ${resultpath}/macaque_downsampled/xtract/masks/${tract}/target.txt

    echo ${resultpath}/macaque_downsampled/xtract/masks/${tract}/target1.nii.gz >> ${resultpath}/macaque_downsampled/xtract/masks/${tract}/target_invert.txt
    echo ${resultpath}/macaque_downsampled/xtract/masks/${tract}/seed.nii.gz >> ${resultpath}/macaque_downsampled/xtract/masks/${tract}/target_invert.txt

done

ptxbin="$FSLDIR/bin/probtrackx2_gpu"

for tract in af_l af_r; do

    ${ptxbin} -s ${resultpath}/macaque_downsampled/DTI.bedpostX/merged \
              -m ${resultpath}/macaque_downsampled/DTI.bedpostX/nodif_brain_mask.nii.gz \
              --nsamples=5000 -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.1 -S 3200 \
              --seed=${resultpath}/macaque_downsampled/xtract/masks/${tract}/seed.nii.gz \
              --waypoints=${resultpath}/macaque_downsampled/xtract/masks/${tract}/target.txt \
              --avoid=${resultpath}/macaque_downsampled/xtract/masks/${tract}/exclude.nii.gz \
              -o density \
              --dir=${resultpath}/macaque_downsampled/xtract/tracts/${tract}

    ${ptxbin} -s ${resultpath}/macaque_downsampled/DTI.bedpostX/merged \
              -m ${resultpath}/macaque_downsampled/DTI.bedpostX/nodif_brain_mask.nii.gz \
              --nsamples=5000 -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.1 -S 3200 \
              --seed=${resultpath}/macaque_downsampled/xtract/masks/${tract}/target.nii.gz \
              --waypoints=${resultpath}/macaque_downsampled/xtract/masks/${tract}/target_invert.txt \
              --avoid=${resultpath}/macaque_downsampled/xtract/masks/${tract}/exclude.nii.gz \
              -o density \
              --dir=${resultpath}/macaque_downsampled/xtract/tracts/${tract}/tractsInv

    ${FSLDIR}/bin/fslmaths "${resultpath}/macaque_downsampled/xtract/tracts/${tract}/density" -add "${resultpath}/macaque_downsampled/xtract/tracts/${tract}/tractsInv/density" "${resultpath}/macaque_downsampled/xtract/tracts/${tract}/sum_density"
    echo "scale=5; `cat "${resultpath}/macaque_downsampled/xtract/tracts/${tract}/waytotal"` + `cat "${resultpath}/macaque_downsampled/xtract/tracts/${tract}/tractsInv/waytotal"` "|bc > "${resultpath}/macaque_downsampled/xtract/tracts/${tract}/sum_waytotal"
    ${FSLDIR}/bin/fslmaths "${resultpath}/macaque_downsampled/xtract/tracts/${tract}/sum_density" -div `cat "${resultpath}/macaque_downsampled/xtract/tracts/${tract}/sum_waytotal"` "${resultpath}/macaque_downsampled/xtract/tracts/${tract}/densityNorm"

done
