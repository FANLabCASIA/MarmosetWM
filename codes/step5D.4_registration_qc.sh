#!/bin/bash

mask=/gpfs/userdata/yfwang/MarmosetWM/support_data/MBM_v3.0.1/mask_brain.nii.gz

for sub in `cat /gpfs/userdata/yfwang/MarmosetWM/support_data/marmoset_MBM_list.txt`; do

    echo ${sub}
    subdir=/gpfs/userdata/yfwang/Data/marmoset_MBM_preprocessed/${sub}/affine/ind2MBMv3

    # CreateJacobianDeterminantImage 3 ${subdir}/ind2MBMv31Warp.nii.gz ${subdir}/ind2MBMv31Warp_detJ.nii.gz 0 1
    # CreateJacobianDeterminantImage 3 ${subdir}/ind2MBMv31Warp.nii.gz ${subdir}/ind2MBMv31Warp_logJ.nii.gz 1 1
    
    # CreateJacobianDeterminantImage 3 ${subdir}/ind2MBMv31InverseWarp.nii.gz ${subdir}/ind2MBMv31InverseWarp_detJ.nii.gz 0 1
    # CreateJacobianDeterminantImage 3 ${subdir}/ind2MBMv31InverseWarp.nii.gz ${subdir}/ind2MBMv31InverseWarp_logJ.nii.gz 1 1

    fslmaths ${subdir}/ind2MBMv31Warp_detJ.nii.gz -mas ${mask} ${subdir}/ind2MBMv31Warp_detJ_brain.nii.gz
    fslmaths ${subdir}/ind2MBMv31Warp_logJ.nii.gz -mas ${mask} ${subdir}/ind2MBMv31Warp_logJ_brain.nii.gz

    fslmaths ${subdir}/ind2MBMv31InverseWarp_detJ.nii.gz -mas ${mask} ${subdir}/ind2MBMv31InverseWarp_detJ_brain.nii.gz
    fslmaths ${subdir}/ind2MBMv31InverseWarp_logJ.nii.gz -mas ${mask} ${subdir}/ind2MBMv31InverseWarp_logJ_brain.nii.gz
done
