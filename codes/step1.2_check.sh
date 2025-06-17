#!/bin/bash

fiber_list=/n02dat01/users/yfwang/MarmosetWM/result/protocols_v1/fiberlist.txt
# fiber_list=/n02dat01/users/yfwang/MarmosetWM/result/protocols_v1.1/fiberlist.txt
sub_list=/n02dat01/users/yfwang/Data/marmoset_MBM/marmoset_MBM_list.txt
# sub_list=/n02dat01/users/yfwang/Data/marmoset_brain_minds/list_t1_dwi.txt

resultpath=/n02dat01/users/yfwang/MarmosetWM/result/xtract_result_v1
# resultpath=/n02dat01/users/yfwang/MarmosetWM/result/xtract_result_v1.1_MBM
# resultpath=/n02dat01/users/yfwang/MarmosetWM/result/xtract_result_v1.1_minds

for fiber in `cat ${fiber_list}`; do
    for sub in `cat ${sub_list}`; do

        subdir=${resultpath}/${sub}
        if [ ! -f ${subdir}/xtract/tracts/${fiber}/densityNorm.nii.gz ]; then
            echo ${fiber}-${sub}
        fi
    done
done
