#!/bin/bash

for sub in `cat /gpfs/userdata/yfwang/preprocess_mrtrix/human/HCP40_list.txt`; do

    echo ${sub}

    mv /gpfs/userdata/yfwang/MarmosetWM/tmp/${sub}/* /gpfs/userdata/yfwang/preprocess_mrtrix/human/${sub}

    # subdir=/gpfs/userdata/yfwang/MarmosetWM/tmp/${sub}
    # mkdir -p ${subdir}

    # if [ -f /mgtdat/Mouse_jlh/Data/cpy_SC_40/${sub}/5tt.freesurfer.mif ]; then
    #     cp /mgtdat/Mouse_jlh/Data/cpy_SC_40/${sub}/5tt.freesurfer.mif ${subdir}
    # elif [ -f /n05dat/wyshi/backup/n02_wyshi/HCP_Connectome_40M/${sub}.tar.gz ]; then
    #     cp /n05dat/wyshi/backup/n02_wyshi/HCP_Connectome_40M/${sub}.tar.gz ${subdir}
    #     echo ${sub}-"gz"
    # else
    #     echo ${sub}-"!!"
    # fi

    # mrconvert ${subdir}/5tt.freesurfer.mif ${subdir}/5tt.freesurfer.nii.gz -force
    # fslroi ${subdir}/5tt.freesurfer.nii.gz ${subdir}/5tt.freesurfer.cgm.nii.gz 0 1
    # fslroi ${subdir}/5tt.freesurfer.nii.gz ${subdir}/5tt.freesurfer.sgm.nii.gz 1 1
    # fslroi ${subdir}/5tt.freesurfer.nii.gz ${subdir}/5tt.freesurfer.wm.nii.gz 2 1
    # fslroi ${subdir}/5tt.freesurfer.nii.gz ${subdir}/5tt.freesurfer.csf.nii.gz 3 1
    # fslroi ${subdir}/5tt.freesurfer.nii.gz ${subdir}/5tt.freesurfer.path.nii.gz 4 1
    
done

matlab -nodisplay -nosplash -r "extract_volume; exit"
