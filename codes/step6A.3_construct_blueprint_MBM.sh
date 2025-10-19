#!/bin/bash
#SBATCH --job-name=marmoset_bp_MBM
#SBATCH --output=log/marmoset_bp_MBM.%A_%a.out
#SBATCH --error=log/marmoset_bp_MBM.%A_%a.out
#SBATCH --partition=cpu
#SBATCH --array=0-23

datapath=/gpfs/userdata/yfwang/Data/marmoset_MBM_preprocessed
scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script
resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/xtract_result_MBM
supportdatapath=/gpfs/userdata/yfwang/MarmosetWM/support_data
recipespath=/gpfs/userdata/yfwang/MarmosetWM/result/protocols

arr=(`cat ${supportdatapath}/marmoset_MBM_list.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

subdir=${resultpath}/${sub}


function join_str { local IFS="$1"; shift; echo "$*"; }
unset tracts
for t in `cat ${recipespath}/fiberlist.txt`; do
    tracts+=($t)
done
# build comma separated tract_list for python usage later
tract_list=`join_str , ${tracts[@]}`

if [ ! -f ${subdir}/${sub}_BP.LR.dscalar.nii ]; then

    mkdir -p ${subdir}/temp_xtract

    for t in ${tracts[@]}; do
        cp ${subdir}/xtract/tracts/${t}/densityNorm.nii.gz ${subdir}/temp_xtract/${t}.nii.gz
        fslmaths ${subdir}/temp_xtract/${t}.nii.gz -thr 0.001 ${subdir}/temp_xtract/${t}.nii.gz
    done

    pbx_dir_L=${datapath}/${sub}/${sub}_L_probtrackx_omatrix2
    pbx_dir_R=${datapath}/${sub}/${sub}_R_probtrackx_omatrix2
    white_surf_L=${datapath}/${sub}/surf/DTI_lh_white.surf.gii
    white_surf_R=${datapath}/${sub}/surf/DTI_rh_white.surf.gii
    roi_L=${supportdatapath}/surf/surfFS.lh.atlasroi.shape.gii
    roi_R=${supportdatapath}/surf/surfFS.rh.atlasroi.shape.gii

    python ${scriptpath}/util/create_blueprint.py ${subdir}/temp_xtract \
                                                  ${pbx_dir_L},${pbx_dir_R} \
                                                  ${white_surf_L},${white_surf_R} \
                                                  ${roi_L},${roi_R} \
                                                  ${tract_list} \
                                                  0 \
                                                  0 \
                                                  ${sub}
    rm -r ${subdir}/temp_xtract
fi
