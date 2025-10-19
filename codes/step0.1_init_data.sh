#!/bin/bash
#SBATCH --job-name=init
#SBATCH --output=log/init.%j.out
#SBATCH --error=log/init.%j.out
#SBATCH --partition=cpu

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result
supportdatapath=/gpfs/userdata/yfwang/MarmosetWM/support_data

path_80=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv2/Marmoset_Brain_Mapping_v2.1.2_20200131
path_200=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1


#########################################################
## registration between 80um template with 200um template
#########################################################

cp ${path_80}/Template_sym_FA_80um.nii.gz ${supportdatapath}
cp ${path_80}/Template_sym_T2_80um.nii.gz ${supportdatapath}
cp ${path_200}/template_DTI_FA_brain.nii.gz ${supportdatapath}
cp ${path_200}/template_T2w_brain.nii.gz ${supportdatapath}

# 80um template -> 200um template
mkdir -p ${resultpath}/affine/FA80temp_200temp
antsRegistrationSyN.sh -d 3 \
                       -f ${path_200}/template_DTI_FA_brain.nii.gz \
                       -m ${path_80}/Template_sym_FA_80um.nii.gz \
                       -o ${resultpath}/affine/FA80temp_200temp/FA              


#######################################################
## extract single white matter tract from 80um template
#######################################################
mkdir -p ${resultpath}/all

cp ${path_80}/MBM_wm_ROIs_1_80um.txt ${resultpath}
cp ${path_80}/MBM_wm_ROIs_2_80um.txt ${resultpath}
cp ${path_80}/MBM_wm_ROIs_3_80um.txt ${resultpath}

# wm 1
i=0
for fiber in `cat ${supportdatapath}/MBM_wm_ROIs_1_80um.txt`; do
    let i=${i}+1
    fslmaths ${path_80}/MBM_wm_ROIs_1_80um.nii.gz -thr ${i} -uthr ${i} -bin ${resultpath}/all/${fiber}.nii.gz
done

# wm 2
i=0
for fiber in `cat ${supportdatapath}/MBM_wm_ROIs_2_80um.txt`; do
    let i=${i}+1
    fslmaths ${path_80}/MBM_wm_ROIs_2_80um.nii.gz -thr ${i} -uthr ${i} -bin ${resultpath}/all/${fiber}.nii.gz
done

# wm 3
i=0
for fiber in `cat ${supportdatapath}/MBM_wm_ROIs_3_80um.txt`; do
    let i=${i}+1
    fslmaths ${path_80}/MBM_wm_ROIs_3_80um.nii.gz -thr ${i} -uthr ${i} -bin ${resultpath}/all/${fiber}.nii.gz
done


########################################################
## register single white matter tracts to 200um template
########################################################
# e.g.
resultpath_fiber=${resultpath}/fibers_delineation/ilf
mkdir -p ${resultpath_fiber}

for fiber in inferior_longitudinal_fasciculus; do

    echo ${fiber}
    antsApplyTransforms -d 3 \
                        -i ${resultpath}/all/${fiber}.nii.gz \
                        -o ${resultpath_fiber}/${fiber}_MBM_in_0.2mm.nii.gz \
                        -r ${supportdatapath}/template_DTI_FA_brain.nii.gz \
                        -t ${resultpath}/affine/FA80temp_200/FA0GenericAffine.mat \
                        -t ${resultpath}/affine/FA80temp_200/FA1Warp.nii.gz \
                        -n NearestNeighbor
done
