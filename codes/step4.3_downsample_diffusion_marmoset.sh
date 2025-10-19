#!/bin/bash
#SBATCH --job-name=downsample_marmoset
#SBATCH --output=downsample_marmoset.%j.out
#SBATCH --error=downsample_marmoset.%j.out
#SBATCH --partition=g3090
#SBATCH --gres=gpu:1

datapath=/gpfs/userdata/yfwang/MarmosetWM/result/hires_tracking
resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/hires_four_species

#############
## downsample
#############
mkdir -p ${resultpath}/marmoset_downsampled
mkdir -p ${resultpath}/marmoset_downsampled/DTI

3dresample -inset ${datapath}/DTI/data.nii.gz \
           -prefix ${resultpath}/marmoset_downsampled/DTI/data.nii.gz \
           -dxyz 0.128 0.128 0.128

3dresample -inset ${datapath}/DTI/nodif_brain_mask.nii.gz \
           -prefix ${resultpath}/marmoset_downsampled/DTI/nodif_brain_mask.nii.gz \
           -dxyz 0.128 0.128 0.128

cp ${datapath}/DTI/bvals ${resultpath}/marmoset_downsampled/DTI
cp ${datapath}/DTI/bvecs ${resultpath}/marmoset_downsampled/DTI

dtifit -k ${resultpath}/marmoset_downsampled/DTI/data.nii.gz -o ${resultpath}/marmoset_downsampled/DTI/dti -m ${resultpath}/marmoset_downsampled/DTI/nodif_brain_mask.nii.gz -r ${resultpath}/marmoset_downsampled/DTI/bvecs -b ${resultpath}/marmoset_downsampled/DTI/bvals --save_tensor

${FSLDIR}/bin/bedpostx_gpu ${resultpath}/marmoset_downsampled/DTI

#########
## xtract
#########
mkdir -p ${resultpath}/marmoset_downsampled/xtract
mkdir -p ${resultpath}/marmoset_downsampled/xtract/masks

for tract in af_l af_r; do

    mkdir -p ${resultpath}/marmoset_downsampled/xtract/masks/${tract}
        
    3dresample -inset ${resultpath}/../hires_af_slf/masks/${tract}/seed.nii.gz \
               -prefix ${resultpath}/marmoset_downsampled/xtract/masks/${tract}/seed.nii.gz \
               -dxyz 0.128 0.128 0.128

    3dresample -inset ${resultpath}/../hires_af_slf/masks/${tract}/target.nii.gz \
               -prefix ${resultpath}/marmoset_downsampled/xtract/masks/${tract}/target.nii.gz \
               -dxyz 0.128 0.128 0.128

    3dresample -inset ${resultpath}/../hires_af_slf/masks/${tract}/target1.nii.gz \
               -prefix ${resultpath}/marmoset_downsampled/xtract/masks/${tract}/target1.nii.gz \
               -dxyz 0.128 0.128 0.128

    3dresample -inset ${resultpath}/../hires_af_slf/masks/${tract}/target2.nii.gz \
               -prefix ${resultpath}/marmoset_downsampled/xtract/masks/${tract}/target2.nii.gz \
               -dxyz 0.128 0.128 0.128

    3dresample -inset ${resultpath}/../hires_af_slf/masks/${tract}/exclude.nii.gz \
               -prefix ${resultpath}/marmoset_downsampled/xtract/masks/${tract}/exclude.nii.gz \
               -dxyz 0.128 0.128 0.128

done

ptxbin="$FSLDIR/bin/probtrackx2_gpu"

for tract in af_l af_r; do

    mkdir -p ${resultpath}/marmoset_downsampled/xtract/tracts/${tract}

    echo ${resultpath}/marmoset_downsampled/xtract/masks/${tract}/target1.nii.gz >> ${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/targets.txt
    echo ${resultpath}/marmoset_downsampled/xtract/masks/${tract}/target2.nii.gz >> ${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/targets.txt

    ${ptxbin} -s ${resultpath}/marmoset_downsampled/DTI.bedpostX/merged \
              -m ${resultpath}/marmoset_downsampled/DTI.bedpostX/nodif_brain_mask.nii.gz \
              --nsamples=10000 -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.1 -S 3200 \
              --seed=${resultpath}/marmoset_downsampled/xtract/masks/${tract}/seed.nii.gz \
              --waypoints=${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/target.txt \
              --avoid=${resultpath}/marmoset_downsampled/xtract/masks/${tract}/exclude.nii.gz \
              -o density \
              --dir=${resultpath}/marmoset_downsampled/xtract/tracts/${tract}

    ${ptxbin} -s ${resultpath}/marmoset_downsampled/DTI.bedpostX/merged \
              -m ${resultpath}/marmoset_downsampled/DTI.bedpostX/nodif_brain_mask.nii.gz \
              --nsamples=10000 -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=0.1 -S 3200 \
              --seed=${resultpath}/marmoset_downsampled/xtract/masks/${tract}/target.nii.gz \
              --waypoints=${resultpath}/marmoset_downsampled/xtract/masks/${tract}/seed.nii.gz \
              --avoid=${resultpath}/marmoset_downsampled/xtract/masks/${tract}/exclude.nii.gz \
              -o density \
              --dir=${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/tractsInv

    ${FSLDIR}/bin/fslmaths "${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/density" -add "${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/tractsInv/density" "${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/sum_density"
    echo "scale=5; `cat "${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/waytotal"` + `cat "${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/tractsInv/waytotal"` "|bc > "${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/sum_waytotal"
    ${FSLDIR}/bin/fslmaths "${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/sum_density" -div `cat "${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/sum_waytotal"` "${resultpath}/marmoset_downsampled/xtract/tracts/${tract}/densityNorm"

done
