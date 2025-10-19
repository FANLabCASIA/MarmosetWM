#!/bin/bash

datapath=/n02dat01/users/yfwang/Data/Duke_Macaque_DTI/m30

fslroi ${datapath}/rawdata/m030.nii.gz ${datapath}/nodif.nii.gz 0 1 

mrtransform -linear ${datapath}/trans.txt ${datapath}/nodif.nii.gz ${datapath}/nodif.nii.gz -force
fslreorient2std ${datapath}/nodif.nii.gz ${datapath}/nodif.nii.gz

mrtransform -linear ${datapath}/trans.txt ${datapath}/nodif_brain_mask.nii.gz ${datapath}/nodif_brain_mask.nii.gz -force
fslreorient2std ${datapath}/nodif_brain_mask.nii.gz ${datapath}/nodif_brain_mask.nii.gz

#################
# manually edit #
#################

fslmaths ${datapath}/nodif.nii.gz -mas ${datapath}/nodif_brain_mask_edited.nii.gz ${datapath}/nodif_brain.nii.gz

mkdir -p ${datapath}/DTI
mrtransform -linear ${datapath}/trans.txt ${datapath}/rawdata/m030.nii.gz ${datapath}/DTI/data.nii.gz -force
fslreorient2std ${datapath}/DTI/data.nii.gz ${datapath}/DTI/data.nii.gz
cp ${datapath}/nodif_brain_mask_edited.nii.gz ${datapath}/DTI/nodif_brain_mask.nii.gz

###################
# transform bvecs #
###################

cp ${subdir}/DTI/data.nii.gz ${subdir}/DTI/dwi.nii.gz
cp ${subdir}/DTI/bvals ${subdir}/DTI/dwi.bvals
cp ${subdir}/DTI/bvecs ${subdir}/DTI/dwi.bvecs
cp ${subdir}/DTI/nodif_brain_mask.nii.gz ${subdir}/DTI/nodif_brain_mask.nii.gz

# denoise and eddy correct
dwidenoise ${subdir}/DTI/dwi.nii.gz ${subdir}/DTI/dwi_denoised.nii.gz
eddy_correct ${subdir}/DTI/dwi_denoised.nii.gz ${subdir}/DTI/data.nii.gz 0
fdt_rotate_bvecs ${subdir}/DTI/dwi.bvecs ${subdir}/DTI/bvecs ${subdir}/DTI/data.ecclog
cp ${subdir}/DTI/dwi.bvals ${subdir}/DTI/bvals

fslroi ${subdir}/DTI/data.nii.gz ${subdir}/DTI/nodif 0 1
fslmaths ${subdir}/DTI/nodif.nii.gz -mas ${subdir}/DTI/nodif_brain_mask.nii.gz ${subdir}/DTI/nodif_brain.nii.gz

# dtifit
dtifit -k ${subdir}/DTI/data.nii.gz -o ${subdir}/DTI/dti -m ${subdir}/DTI/nodif_brain_mask.nii.gz -r ${subdir}/DTI/bvecs -b ${subdir}/DTI/bvals --save_tensor

# bedpostx
${FSLDIR}/bin/bedpostx_gpu ${subdir}/DTI
#${FSLDIR}/bin/bedpostx_gpu /n02dat01/users/yfwang/Data/Duke_Macaque_DTI/m30/DTI

# affine
mkdir -p ${subdir}/affine
antsRegistrationSyN.sh -d 3 \
                       -f /n02dat01/users/yfwang/Templates/CIVM_Template/b0_03mm_Template_BNA.nii.gz \
                       -m ${subdir}/DTI/nodif_brain.nii.gz \
                       -o ${subdir}/affine/indi2CIVM03

# mrtrix
mkdir -p ${subdir}/FOD
mrconvert ${subdir}/DTI/data.nii.gz ${subdir}/FOD/data.mif -fslgrad ${subdir}/DTI/bvecs ${subdir}/DTI/bvals -force -nthread 16
dwi2response dhollander ${subdir}/FOD/data.mif ${subdir}/FOD/WM.res ${subdir}/FOD/GM.res ${subdir}/FOD/CSF.res -mask ${subdir}/DTI/nodif_brain_mask.nii.gz -force -nthread 16
dwi2FOD msmt_csd ${subdir}/FOD/data.mif ${subdir}/FOD/WM.res ${subdir}/FOD/fod_WM.mif ${subdir}/FOD/GM.res ${subdir}/FOD/fod_GM.mif ${subdir}/FOD/CSF.res ${subdir}/FOD/fod_CSF.mif -mask ${subdir}/DTI/nodif_brain_mask.nii.gz -force -nthread 16

