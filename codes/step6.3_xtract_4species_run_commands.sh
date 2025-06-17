#!/bin/bash

PIPELINE=/n05dat/yfwang/user/MarmosetWM/script

for species in macaque; do
    if [ "${species}" == "human" ]; then
        bpxdir=/n02dat01/users/yfwang/Data/MGH/allData/DTI.bedpostX
        xtractdir=/n02dat01/users/yfwang/MarmosetWM/result/hires_validation/four_species_validation/human/xtract
        steplength=0.5
    elif [ "${species}" == "chimp" ]; then
        bpxdir=/n02dat01/users/yfwang/Data/chimp_ecb/DTI.bedpostX
        xtractdir=/n02dat01/users/yfwang/MarmosetWM/result/hires_validation/four_species_validation/chimp/xtract
        steplength=0.2
    elif [ "${species}" == "macaque" ]; then
        bpxdir=/n05dat/yfwang/backup_monkey/Duke_Macaque_DTI/m30/DTI.bedpostX
        xtractdir=/n05dat/yfwang/user/MarmosetWM/result/hires_validation/four_species_validation/macaque/xtract
        steplength=0.1
    elif [ "${species}" == "marmoset" ]; then
        bpxdir=/n02dat01/users/yfwang/MarmosetWM/result/marmoset_80um/DTI.bedpostX
        xtractdir=/n02dat01/users/yfwang/MarmosetWM/result/AF_validation/AF_SLF/xtract
        steplength=0.02
    fi

    for fiber in af_l; do
        for step in 123; do
            cat > ${PIPELINE}/cmd/${species}_${fiber}_${step}.slurm <<EOF
#!/bin/bash 
#SBATCH -J ${species}_${fiber}_${step}
#SBATCH -o ${PIPELINE}/log/${species}_${fiber}_${step}.%j.out
#SBATCH -e ${PIPELINE}/log/${species}_${fiber}_${step}.%j.out
#SBATCH -p ga10
#SBATCH --gres=gpu:1

bash ${PIPELINE}/xtract_commands_${species}.sh ${fiber} ${bpxdir} ${xtractdir} ${step} ${steplength} 1
EOF
            sbatch ${PIPELINE}/cmd/${species}_${fiber}_${step}.slurm
        done
    done
done
 