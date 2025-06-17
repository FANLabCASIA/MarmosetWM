#!/bin/bash
#SBATCH --job-name=marmoset_bp
#SBATCH --output=log/marmoset_bp.%A_%a.out
#SBATCH --error=log/marmoset_bp.%A_%a.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --exclude=n08
#SBATCH --array=109,104

arr=(`cat /n05dat/yfwang/backup_marmoset/marmoset_brain_minds/list_t1_dwi_aging.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

datadir=/n05dat/yfwang/backup_marmoset/marmoset_brain_minds/invivo
subdir=/n05dat/yfwang/user/MarmosetWM/result/xtract_result_v1.1_minds/${sub}

recipespath=/n05dat/yfwang/user/MarmosetWM/result/protocols_v1.1

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
        # flirt -in ${subdir}/temp_xtract/${t}.nii.gz -out ${subdir}/temp_xtract/${t}.nii.gz -ref ${subdir}/DTI.bedpostX/nodif_brain_mask.nii.gz -applyisoxfm 2 -interp trilinear
        fslmaths ${subdir}/temp_xtract/${t}.nii.gz -thr 0.001 ${subdir}/temp_xtract/${t}.nii.gz
    done

    pbx_dir_L=${datadir}/${sub}/${sub}_L_probtrackx_omatrix2
    pbx_dir_R=${datadir}/${sub}/${sub}_R_probtrackx_omatrix2
    white_surf_L=${datadir}/${sub}/surf/DTI_lh_white.surf.gii
    white_surf_R=${datadir}/${sub}/surf/DTI_rh_white.surf.gii
    roi_L=/n05dat/yfwang/user/MarmosetWM/support_data/surf/surfFS.lh.atlasroi.shape.gii
    roi_R=/n05dat/yfwang/user/MarmosetWM/support_data/surf/surfFS.rh.atlasroi.shape.gii

    python /n05dat/yfwang/user/MarmosetWM/script/util/create_blueprint.py ${subdir}/temp_xtract \
                                                                          ${pbx_dir_L},${pbx_dir_R} \
                                                                          ${white_surf_L},${white_surf_R} \
                                                                          ${roi_L},${roi_R} \
                                                                          ${tract_list} \
                                                                          0 \
                                                                          0 \
                                                                          ${sub}
    rm -r ${subdir}/temp_xtract
fi
