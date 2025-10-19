#!/bin/bash

scriptpath=/gpfs/userdata/yfwang/MarmosetWM/script
resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/hires_four_species

for species in human chimp macaque; do
    if [ "${species}" == "human" ]; then
        bpxdir=/n08d03/atlas_group/yfwang/Data/backup_human/MGH/allData/DTI.bedpostX
        xtractdir=${resultpath}/human/xtract
        steplength=0.5
    elif [ "${species}" == "chimp" ]; then
        bpxdir=/gpfs/userdata/yfwang/Data/chimp_ecb/DTI.bedpostX
        xtractdir=${resultpath}/chimp/xtract
        steplength=0.2
    elif [ "${species}" == "macaque" ]; then
        bpxdir=/gpfs/userdata/yfwang/Data/Duke_Macaque_DTI/m30/DTI.bedpostX
        xtractdir=${resultpath}/macaque/xtract
        steplength=0.1
    elif [ "${species}" == "marmoset" ]; then
        bpxdir=/gpfs/userdata/yfwang/MarmosetWM/result/hires_tracking/DTI.bedpostX
        xtractdir=/gpfs/userdata/yfwang/MarmosetWM/result/hires_af_slf/xtract
        steplength=0.02
    fi

    for fiber in af_l af_r; do
        for step in 123; do
            cat > ${scriptpath}/cmd/${species}_${fiber}_${step}.slurm <<EOF
#!/bin/bash 
#SBATCH -J ${species}_${fiber}_${step}
#SBATCH -o ${scriptpath}/log/${species}_${fiber}_${step}.%j.out
#SBATCH -e ${scriptpath}/log/${species}_${fiber}_${step}.%j.out
#SBATCH -p ga10
#SBATCH --gres=gpu:1

bash ${scriptpath}/util/xtract_commands_${species}.sh ${fiber} ${bpxdir} ${xtractdir} ${step} ${steplength} 1
EOF
            sbatch ${scriptpath}/cmd/${species}_${fiber}_${step}.slurm
        done
    done
done
 