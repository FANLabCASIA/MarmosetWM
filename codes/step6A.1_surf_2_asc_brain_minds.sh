#!/bin/bash
#SBATCH --job-name=marmoset_surf_2_asc
#SBATCH --output=log/marmoset_surf_2_asc.%j.out
#SBATCH --error=log/marmoset_surf_2_asc.%j.out
#SBATCH --partition=cpu

scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script
resultpath=/gpfs/userdata/yfwang/MarmosetWM/support_data/surf

for hemi in lh rh; do

    ## convert white pial gii to ASCII
    surf2surf -i  ${resultpath}/surfFS.${hemi}.white.surf.gii -o ${resultpath}/surfFS.${hemi}.white.asc --outputtype=ASCII --values=${resultpath}/surfFS.${hemi}.atlasroi.shape.gii
    surf2surf -i  ${resultpath}/surfFS.${hemi}.pial.surf.gii -o ${resultpath}/surfFS.${hemi}.pial.asc --outputtype=ASCII --values=${resultpath}/surfFS.${hemi}.atlasroi.shape.gii
done

python ${scriptpath}/util/surf_2_asc_minds.py
