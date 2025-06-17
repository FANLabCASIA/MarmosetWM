#!/bin/bash
#SBATCH --job-name=marmoset_wb_pbx
#SBATCH --output=log/marmoset_wb_pbx.%A_%a.out
#SBATCH --error=log/marmoset_wb_pbx.%A_%a.out
#SBATCH --partition=g3090
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --array=109

arr=(`cat /n05dat/yfwang/backup_marmoset/marmoset_brain_minds/list_t1_dwi_aging.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

datadir=/n05dat/yfwang/backup_marmoset/marmoset_brain_minds/invivo
subdir=${datadir}/${sub}

mrconvert ${subdir}/DTI.bedpostX/nodif_brain_mask.nii.gz ${subdir}/DTI.bedpostX/nodif_brain_mask.nii.gz -force

for hemi in L; do

    if [ "${hemi}" == "L" ]; then
        hem=lh
    else
        hem=rh
    fi

    # white/pial surface
    white_asc=${subdir}/surf/DTI_${hem}_white.asc
    pial_asc=${subdir}/surf/DTI_${hem}_pial.asc
    
    bpx=${subdir}/DTI.bedpostX/merged
    mask=${subdir}/DTI.bedpostX/nodif_brain_mask
    xfm=${datadir}/identify_mat
    seedref=${subdir}/DTI.bedpostX/nodif_brain_mask
    target2=${subdir}/DTI.bedpostX/nodif_brain_mask
    stop=${subdir}/surf/stop_ants
    wtstop=${subdir}/surf/wtstop_ants

    seed=${subdir}/surf/DTI_${hem}_white.asc
    pbxdir=${subdir}/${sub}_${hemi}_probtrackx_omatrix2
    mkdir -p ${pbxdir}

    # if [ ! -f ${pbxdir}/fdt_matrix2.dot ]; then
        ${FSLDIR}/bin/probtrackx2_gpu10.2 --samples=${bpx} --mask=${mask} --xfm=${xfm} --seedref=${seedref} \
                                      -P 5000 --loopcheck --forcedir -c 0.2 --sampvox=2 --randfib=1 --stop=${stop} --forcefirststep \
                                      -x ${seed} --omatrix2 --target2=${target2} --wtstop=${wtstop} --dir=${pbxdir} --opd -o ${hemi}
    # fi
done
