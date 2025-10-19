#!/bin/bash

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/hires_tracking
supportdatapath=/gpfs/userdata/yfwang/MarmosetWM/support_data

#######################
## probtrackx + Paxinos
#######################
WD=${resultpath}/dorsal_probtrackx2

for ROI1 in A45; do
    for ROI2 in AuCM Tpt; do
        for pathway in dorsal ventral; do
            for hemi in left right; do

                echo ${ROI1}-${ROI2}-${pathway}-${hemi}:
                cat ${WD}/${ROI1}_${ROI2}_${hemi}_${pathway}/waytotal

                echo ${ROI2}-${ROI1}-${pathway}-${hemi}:
                cat ${WD}/${ROI2}_${ROI1}_${hemi}_${pathway}/waytotal
            done
        done
    done
done

##################
## ifod2 + Paxinos
##################
WD=${resultpath}/dorsal_ifod2

for ROI1 in A45; do
    for ROI2 in AuCM Tpt; do
        for pathway in dorsal ventral; do
            for hemi in left right; do

                echo ${ROI1}-${ROI2}-${pathway}-${hemi}:
                tckinfo ${WD}/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}_${pathway}.tck | grep -w "count" | awk '{print $2}'

                echo ${ROI2}-${ROI1}-${pathway}-${hemi}:
                tckinfo ${WD}/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}_${pathway}.tck | grep -w "count" | awk '{print $2}'
            done
        done
    done
done

#########
## allMBM
#########
WD=${resultpath}/dorsal_allMBM

for sub in `${supportdatapath}/marmoset_MBM_list.txt`; do
    
    echo ${sub}
    subdir=${WD}/${sub}/ifod2

    for ROI1 in A45; do
        for ROI2 in AuCM Tpt; do
            for pathway in dorsal ventral; do
                for hemi in left right; do

                    sum=$( (tckinfo ${subdir}/${ROI1}_${ROI2}_${hemi}/${ROI1}_${ROI2}_${hemi}_${pathway}.tck; tckinfo ${subdir}/${ROI2}_${ROI1}_${hemi}/${ROI2}_${ROI1}_${hemi}_${pathway}.tck) | grep -w "count:" | awk '{s+=$2} END{print s}' )
                    echo ${sum} >> ${WD}/result/${ROI1}_${ROI2}_${pathway}_${hemi}.txt
                done
            done
        done
    done
done