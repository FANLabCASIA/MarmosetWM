#!/bin/bash
#SBATCH -J bed_MGH
#SBATCH -o log/bed_MGH.%j.out
#SBATCH -e log/bed_MGH.%j.out
#SBATCH -p gpu
#SBATCH --nodelist=n19
#SBATCH --gres=gpu:1

datapath=/n02dat01/users/yfwang/Data/MGH

# mkdir -p ${datapath}/allData/DTI

# fslmerge -t ${datapath}/allData/DTI/data.nii.gz \
#             ${datapath}/processedDWI_session1_subset01/session1_subset01.nii.gz \
#             ${datapath}/processedDWI_session1_subset02/session1_subset02.nii.gz \
#             ${datapath}/processedDWI_session2_subset03/session2_subset03.nii.gz \
#             ${datapath}/processedDWI_session2_subset04/session2_subset04.nii.gz \
#             ${datapath}/processedDWI_session3_subset05/session3_subset05.nii.gz \
#             ${datapath}/processedDWI_session3_subset06/session3_subset06.nii.gz \
#             ${datapath}/processedDWI_session4_subset07/session4_subset07.nii.gz \
#             ${datapath}/processedDWI_session4_subset08/session4_subset08.nii.gz \
#             ${datapath}/processedDWI_session5_subset09/session5_subset09.nii.gz \
#             ${datapath}/processedDWI_session5_subset10/session5_subset10.nii.gz \
#             ${datapath}/processedDWI_session6_subset11/session6_subset11.nii.gz \
#             ${datapath}/processedDWI_session6_subset12/session6_subset12.nii.gz \
#             ${datapath}/processedDWI_session7_subset13/session7_subset13.nii.gz \
#             ${datapath}/processedDWI_session7_subset14/session7_subset14.nii.gz \
#             ${datapath}/processedDWI_session8_subset15/session8_subset15.nii.gz \
#             ${datapath}/processedDWI_session8_subset16/session8_subset16.nii.gz \
#             ${datapath}/processedDWI_session9_subset17/session9_subset17.nii.gz \
#             ${datapath}/processedDWI_session9_subset18/session9_subset18.nii.gz

# cp ${datapath}/DTI/Bval.bval ${datapath}/allData/DTI/bvals
# cp ${datapath}/DTI/Bvec.bvec ${datapath}/allData/DTI/bvecs
# fslmaths ${datapath}/DTI/allData_DTI_FA.nii.gz -bin ${datapath}/allData/DTI/nodif_brain_mask.nii.gz

# fslmaths ${datapath}/allData/DTI/data.nii.gz ${datapath}/allData/DTI/nodif.nii.gz 0 1
# fslmaths ${datapath}/allData/DTI/nodif.nii.gz -mas ${datapath}/allData/DTI/nodif_brain_mask.nii.gz ${datapath}/allData/DTI/nodif_brain.nii.gz

# dtifit -k ${datapath}/allData/DTI/data.nii.gz -o ${datapath}/allData/DTI/dti -m ${datapath}/allData/DTI/nodif_brain_mask.nii.gz -r ${datapath}/allData/DTI/bvecs -b ${datapath}/allData/DTI/bvals

${FSLDIR}/bin/bedpostx_gpu ${datapath}/allData/DTI

