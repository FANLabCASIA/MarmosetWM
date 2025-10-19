#!/bin/bash

fiber=$1
bpxdir=$2
xtractdir=$3
step=$4
steplength=$5
gpu=$6

if [ ${gpu} -eq 0 ]; then
    ptxbin="$FSLDIR/bin/probtrackx2"
else
    ptxbin="$FSLDIR/bin/probtrackx2_gpu"
fi

if [ ${step} -eq 1 ]; then
    echo "1 mode"

    ${ptxbin} -s ${bpxdir}/merged \
              -m ${bpxdir}/nodif_brain_mask.nii.gz \
              --nsamples=10000 -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=${steplength} -S 3200 \
              --seed=${xtractdir}/masks/${fiber}/seed.nii.gz \
              --waypoints=${xtractdir}/masks/${fiber}/target.txt \
              --avoid=${xtractdir}/masks/${fiber}/exclude.nii.gz \
              --stop=${xtractdir}/masks/${fiber}/stop.nii.gz \
              -o density \
              --dir=${xtractdir}/tracts/${fiber}

elif [ ${step} -eq 2 ]; then
    echo "2 mode"

    ${ptxbin} -s ${bpxdir}/merged \
              -m ${bpxdir}/nodif_brain_mask.nii.gz \
              --nsamples=10000 -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=${steplength} -S 3200 \
              --seed=${xtractdir}/masks/${fiber}/target.nii.gz \
              --waypoints=${xtractdir}/masks/${fiber}/target_invert.txt \
              --avoid=${xtractdir}/masks/${fiber}/exclude.nii.gz \
              --stop=${xtractdir}/masks/${fiber}/stop.nii.gz \
              -o density \
              --dir=${xtractdir}/tracts/${fiber}/tractsInv

elif [ ${step} -eq 3 ]; then
    echo "3 mode"

    ${FSLDIR}/bin/fslmaths "${xtractdir}/tracts/${fiber}/density" -add "${xtractdir}/tracts/${fiber}/tractsInv/density" "${xtractdir}/tracts/${fiber}/sum_density"
    echo "scale=5; `cat "${xtractdir}/tracts/${fiber}/waytotal"` + `cat "${xtractdir}/tracts/${fiber}/tractsInv/waytotal"` "|bc > "${xtractdir}/tracts/${fiber}/sum_waytotal"
    ${FSLDIR}/bin/fslmaths "${xtractdir}/tracts/${fiber}/sum_density" -div `cat "${xtractdir}/tracts/${fiber}/sum_waytotal"` "${xtractdir}/tracts/${fiber}/densityNorm"

elif [ ${step} -eq 123 ]; then
    echo "123 mode"

    ${ptxbin} -s ${bpxdir}/merged \
              -m ${bpxdir}/nodif_brain_mask.nii.gz \
              --nsamples=10000 -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=${steplength} -S 3200 \
              --seed=${xtractdir}/masks/${fiber}/seed.nii.gz \
              --waypoints=${xtractdir}/masks/${fiber}/target.nii.gz \
              --avoid=${xtractdir}/masks/${fiber}/exclude.nii.gz \
              --stop=${xtractdir}/masks/${fiber}/stop.nii.gz \
              -o density \
              --dir=${xtractdir}/tracts/${fiber}

    ${ptxbin} -s ${bpxdir}/merged \
              -m ${bpxdir}/nodif_brain_mask.nii.gz \
              --nsamples=10000 -V 1 --loopcheck --forcedir --opd --ompl --sampvox=1 --randfib=1 --steplength=${steplength} -S 3200 \
              --seed=${xtractdir}/masks/${fiber}/target.nii.gz \
              --waypoints=${xtractdir}/masks/${fiber}/seed.nii.gz \
              --avoid=${xtractdir}/masks/${fiber}/exclude.nii.gz \
              --stop=${xtractdir}/masks/${fiber}/stop.nii.gz \
              -o density \
              --dir=${xtractdir}/tracts/${fiber}/tractsInv

    ${FSLDIR}/bin/fslmaths "${xtractdir}/tracts/${fiber}/density" -add "${xtractdir}/tracts/${fiber}/tractsInv/density" "${xtractdir}/tracts/${fiber}/sum_density"
    echo "scale=5; `cat "${xtractdir}/tracts/${fiber}/waytotal"` + `cat "${xtractdir}/tracts/${fiber}/tractsInv/waytotal"` "|bc > "${xtractdir}/tracts/${fiber}/sum_waytotal"
    ${FSLDIR}/bin/fslmaths "${xtractdir}/tracts/${fiber}/sum_density" -div `cat "${xtractdir}/tracts/${fiber}/sum_waytotal"` "${xtractdir}/tracts/${fiber}/densityNorm"

fi
