#!/bin/bash
#SBATCH --job-name=marmoset_wb_pbx_MBM
#SBATCH --output=log/marmoset_wb_pbx_MBM.%A_%a.out
#SBATCH --error=log/marmoset_wb_pbx_MBM.%A_%a.out
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --array=0-23

resultpath=/gpfs/userdata/yfwang/Data/marmoset_MBM_preprocessed

arr=(`cat ${resultpath}/marmoset_MBM_list.txt`)
sub=${arr[$SLURM_ARRAY_TASK_ID]}

subdir=${resultpath}/${sub}
mrconvert ${subdir}/DTI.bedpostX/nodif_brain_mask.nii.gz ${subdir}/DTI.bedpostX/nodif_brain_mask.nii.gz -force

for hemi in L R; do

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
    xfm=${resultpath}/identify_mat
    seedref=${subdir}/DTI.bedpostX/nodif_brain_mask
    target2=${subdir}/DTI.bedpostX/nodif_brain_mask
    stop=${subdir}/surf/stop_ants
    wtstop=${subdir}/surf/wtstop_ants

    seed=${subdir}/surf/DTI_${hem}_white.asc
    pbxdir=${subdir}/${sub}_${hemi}_probtrackx_omatrix2
    mkdir -p ${pbxdir}

    if [ ! -f ${pbxdir}/fdt_matrix2.dot ]; then
        ${FSLDIR}/bin/probtrackx2_gpu --samples=${bpx} --mask=${mask} --xfm=${xfm} --seedref=${seedref} \
                                      -P 5000 --loopcheck --forcedir -c 0.2 --sampvox=2 --randfib=1 --stop=${stop} --forcefirststep \
                                      -x ${seed} --omatrix2 --target2=${target2} --wtstop=${wtstop} --dir=${pbxdir} --opd -o ${hemi}
    fi
done
