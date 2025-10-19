#!/bin/bash

scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script
resultpath=/gpfs/userdata/yfwang/MarmosetWM/result

#######################
## connectivity pattern
#######################
path_80=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv2/Marmoset_Brain_Mapping_v2.1.2_20200131
data_80=/gpfs/userdata/yfwang/Data/marmoset_MBM/MBMv2/DMRI_80um_DWI_Preprocessed_TORTOISE

# register atlas into hires individual b0 space
antsApplyTransforms -d 3 \
                    -i ${path_80}/MBM_cortex_vH_80um.nii.gz \
                    -o ${resultpath}/hires_af_slf/MBMvH_80um.nii.gz \
                    -r ${data_80}/FSL_DTIFIT/DTIFIT_FA.nii.gz \
                    -t ${resultpath}/affine/FA80temp_80indi/FA1Warp.nii.gz \
                    -t ${resultpath}/affine/FA80temp_80indi/FA0GenericAffine.mat \
                    -n NearestNeighbor

matlab -nodisplay -nosplash -r "addpath(genpath('${scriptpath}')); af_slf_projection; exit"

# generate hires surface for visualization
python ${scriptpath}/util/surf_2_asc_hires.py