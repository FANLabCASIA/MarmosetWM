#!/bin/bash
#SBATCH --job-name=marmoset_surf_2_asc
#SBATCH --output=log/marmoset_surf_2_asc.%j.out
#SBATCH --error=log/marmoset_surf_2_asc.%j.out
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --exclude=n05,n15

datapath=/n02dat01/users/yfwang/MarmosetWM/support_data/surf

for hemi in lh rh; do

    ## convert white pial gii to ASCII
    surf2surf -i  ${datapath}/surfFS.${hemi}.white.surf.gii -o ${datapath}/surfFS.${hemi}.white.asc --outputtype=ASCII --values=${datapath}/surfFS.${hemi}.atlasroi.shape.gii
    surf2surf -i  ${datapath}/surfFS.${hemi}.pial.surf.gii -o ${datapath}/surfFS.${hemi}.pial.asc --outputtype=ASCII --values=${datapath}/surfFS.${hemi}.atlasroi.shape.gii
done

python /n02dat01/users/yfwang/MarmosetWM/script/util/surf_2_asc.py
