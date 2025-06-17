#!/bin/bash

# for sub in `cat /n02dat01/users/yfwang/Data/marmoset_MBM/marmoset_MBM_list.txt`; do
    
#     subdir=/n02dat01/users/yfwang/MarmosetWM/result/xtract_result_v1.1_MBM/${sub}
#     if [ ! -f ${subdir}/${sub}_BP.LR.dscalar.nii ]; then
#         echo ${sub}
#     fi
# done


for sub in `cat /n05dat/yfwang/backup_marmoset/marmoset_brain_minds/list_t1_dwi_aging.txt`; do
    
    subdir=/n05dat/yfwang/user/MarmosetWM/result/xtract_result_v1.1_minds/${sub}
    if [ ! -f ${subdir}/${sub}_BP.LR.dscalar.nii ]; then
        echo ${sub}
    fi
done
