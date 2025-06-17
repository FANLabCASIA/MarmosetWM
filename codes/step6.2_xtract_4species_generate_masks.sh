#!/bin/bash

fiber=af_l # af_r

# ## human
# subdir=/n02dat01/users/yfwang/Data/Allen
# recipespath=/n02dat01/users/yfwang/repo/chimpanzee-tractography-protocols-master_earlier/recipes/human/${fiber}
# xtractdir=/n02dat01/users/yfwang/MarmosetWM/result/AF_validation/Four_species/human/xtract

# mkdir -p ${xtractdir}/logs
# mkdir -p ${xtractdir}/masks/${fiber}
# mkdir -p ${xtractdir}/tracts/${fiber}

# for m in seed target exclude stop; do
#     if [ -f ${recipespath}/${m}.nii.gz ]; then

#         ${FSLDIR}/bin/applywarp -i ${recipespath}/${m}.nii.gz \
#                                 -o ${xtractdir}/masks/${fiber}/${m}.nii.gz \
#                                 -w ${subdir}/xfms/mni_2_b0_warp.nii.gz \
#                                 -r ${subdir}/DTI.bedpostX/nodif_brain_mask.nii.gz \
#                                 -d float
#         $FSLDIR/bin/fslmaths ${xtractdir}/masks/${fiber}/${m}.nii.gz -thr 0.1 -bin ${xtractdir}/masks/${fiber}/${m}.nii.gz -odt char
#     fi
# done

# ## chimp
# subdir=/n02dat01/users/yfwang/Data/chimp_ecb
# recipespath=/n02dat01/users/yfwang/repo/chimpanzee-tractography-protocols-master_earlier/recipes/chimp/${fiber}
# xtractdir=/n02dat01/users/yfwang/MarmosetWM/result/AF_validation/Four_species/chimp/xtract

# mkdir -p ${xtractdir}/logs
# mkdir -p ${xtractdir}/masks/${fiber}
# mkdir -p ${xtractdir}/tracts/${fiber}

# for m in seed target exclude stop; do
#     if [ -f ${recipespath}/${m}.nii.gz ]; then

#         antsApplyTransforms -d 3 \
#                             -i ${recipespath}/${m}.nii.gz \
#                             -o ${xtractdir}/masks/${fiber}/${m}.nii.gz \
#                             -r ${subdir}/DTI.bedpostX/nodif_brain_mask.nii.gz \
#                             -t [ ${subdir}/affine/indi2ChimpYerkes290GenericAffine.mat, 1 ] \
#                             -t ${subdir}/affine/indi2ChimpYerkes291InverseWarp.nii.gz
#         ${FSLDIR}/bin/fslmaths ${xtractdir}/masks/${fiber}/${m}.nii.gz -thr 0.1 -bin ${xtractdir}/masks/${fiber}/${m}.nii.gz -odt char
#         ${FSLDIR}/bin/fslcpgeom ${subdir}/DTI.bedpostX/nodif_brain_mask.nii.gz ${xtractdir}/masks/${fiber}/${m}.nii.gz
#         mrconvert ${xtractdir}/masks/${fiber}/${m}.nii.gz ${xtractdir}/masks/${fiber}/${m}.nii.gz -force
#     fi
# done

## macaque
subdir=/n02dat01/users/yfwang/Data/Duke_Macaque_DTI/m30
recipespath=/n02dat01/users/yfwang/repo/chimpanzee-tractography-protocols-master_earlier/recipes/macaque-recipes-CIVM03mm/${fiber}
xtractdir=/n02dat01/users/yfwang/MarmosetWM/result/AF_validation/Four_species/macaque/xtract

mkdir -p ${xtractdir}/logs
mkdir -p ${xtractdir}/masks/${fiber}
mkdir -p ${xtractdir}/tracts/${fiber}

# for m in seed target exclude stop; do
for m in target; do
    if [ -f ${recipespath}/${m}.nii.gz ]; then

        antsApplyTransforms -d 3 \
                            -i ${recipespath}/${m}.nii.gz \
                            -o ${xtractdir}/masks/${fiber}/${m}_test.nii.gz \
                            -r ${subdir}/DTI.bedpostX/nodif_brain_mask.nii.gz \
                            -t [ ${subdir}/affine/indi2CIVM030GenericAffine.mat, 1 ] \
                            -t ${subdir}/affine/indi2CIVM031InverseWarp.nii.gz
        ${FSLDIR}/bin/fslmaths ${xtractdir}/masks/${fiber}/${m}_test.nii.gz -thr 0.1 -bin ${xtractdir}/masks/${fiber}/${m}_test.nii.gz -odt char
        ${FSLDIR}/bin/fslcpgeom ${subdir}/DTI.bedpostX/nodif_brain_mask.nii.gz ${xtractdir}/masks/${fiber}/${m}_test.nii.gz
        mrconvert ${xtractdir}/masks/${fiber}/${m}_test.nii.gz ${xtractdir}/masks/${fiber}/${m}_test.nii.gz -force
    fi
done
