#!/bin/bash

##########################
## PREPARE activation maps
##########################
datapath=/n05dat/yfwang/user/repo/NeuroSynth_20240423
resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/activation/neurosynth
supportdatapath=/n05dat/yfwang/user/Templates/surface/human/

surf_L=${supportdatapath}/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii
surf_R=${supportdatapath}/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii
atlasroi_L=${supportdatapath}/S1200.L.atlasroi.32k_fs_LR.shape.gii
atlasroi_R=${supportdatapath}/S1200.R.atlasroi.32k_fs_LR.shape.gii

for con in speech speech_perception speech_production; do

    wb_command -volume-to-surface-mapping ${datapath}/${con}/${con}-test_z_FDR_0.01.nii.gz ${surf_L} ${resultpath}/human/${con}_association-test_z_FDR_0.01_m.L.func.gii
    wb_command -volume-to-surface-mapping ${datapath}/${con}/${con}-test_z_FDR_0.01.nii.gz ${surf_R} ${resultpath}/human/${con}_association-test_z_FDR_0.01_m.R.func.gii

    wb_command -metric-mask ${resultpath}/human/${con}_association-test_z_FDR_0.01_m.L.func.gii ${atlasroi_L} ${resultpath}/human/${con}_association-test_z_FDR_0.01_m.L.func.gii
    wb_command -metric-mask ${resultpath}/human/${con}_association-test_z_FDR_0.01_m.R.func.gii ${atlasroi_R} ${resultpath}/human/${con}_association-test_z_FDR_0.01_m.R.func.gii
done

######################
## DO the registration
######################
m2h_repo=/n05dat/yfwang/user/repo/alignment_macaque-human-main
m2m_repo=/n05dat/yfwang/user/repo/marmoset-macaque_deformation

human_sphere_32k_l=${m2h_repo}/surfaces/Human/32k_fs_LR/S1200.L.sphere.32k_fs_LR.surf.gii
human_sphere_32k_r=${m2h_repo}/surfaces/Human/32k_fs_LR/S1200.R.sphere.32k_fs_LR.surf.gii
human_sphere_10k_l=${m2h_repo}/surfaces/Human/10k_fs_LR/S1200.L.sphere.10k_fs_LR.surf.gii
human_sphere_10k_r=${m2h_repo}/surfaces/Human/10k_fs_LR/S1200.R.sphere.10k_fs_LR.surf.gii

macaque_sphere_32k_l=${m2h_repo}/surfaces/Macaque/32k_fs_LR/MacaqueYerkes19.L.sphere.32k_fs_LR.surf.gii
macaque_sphere_32k_r=${m2h_repo}/surfaces/Macaque/32k_fs_LR/MacaqueYerkes19.R.sphere.32k_fs_LR.surf.gii
macaque_sphere_10k_l=${m2h_repo}/surfaces/Macaque/10k_fs_LR/MacaqueYerkes19.L.sphere.10k_fs_LR.surf.gii
macaque_sphere_10k_r=${m2h_repo}/surfaces/Macaque/10k_fs_LR/MacaqueYerkes19.R.sphere.10k_fs_LR.surf.gii

marmoset_sphere_32k_l=/gpfs/userdata/yfwang/MarmosetWM/support_data/MBM_v3.0.1/surfFS.lh.sphere.surf.gii
marmoset_sphere_32k_r=/gpfs/userdata/yfwang/MarmosetWM/support_data/MBM_v3.0.1/surfFS.rh.sphere.surf.gii
marmoset_sphere_10k_l=${m2m_repo}/MBM_sym_10k_fs_LR/L.sphere.marmoset.10k_fs_LR.surf.gii
marmoset_sphere_10k_r=${m2m_repo}/MBM_sym_10k_fs_LR/R.sphere.marmoset.10k_fs_LR.surf.gii

## prepare matched sphere
wb_command -set-structure ${marmoset_sphere_32k_l} CORTEX_LEFT -surface-type SPHERICAL
wb_command -set-structure ${marmoset_sphere_32k_r} CORTEX_RIGHT -surface-type SPHERICAL
wb_command -surface-match ${marmoset_sphere_10k_l} ${marmoset_sphere_32k_l} ${resultpath}/surfFS_matched.L.sphere.surf.gii
wb_command -surface-match ${marmoset_sphere_10k_r} ${marmoset_sphere_32k_r} ${resultpath}/surfFS_matched.R.sphere.surf.gii

## deformation
deform_mar2mac_l=${m2m_repo}/deformation/L.marmoset-to-macaque.sphere.reg.10k_fs_LR.surf.gii
deform_mar2mac_r=${m2m_repo}/deformation/R.marmoset-to-macaque.sphere.reg.10k_fs_LR.surf.gii

deform_mac2hum_l=${m2h_repo}/deformation_macaque-human/L.macaque-to-human.sphere.reg.10k_fs_LR.surf.gii
deform_mac2hum_r=${m2h_repo}/deformation_macaque-human/R.macaque-to-human.sphere.reg.10k_fs_LR.surf.gii

deform_hum2mac_l=${m2h_repo}/deformation_macaque-human/L.human-to-macaque.sphere.reg.10k_fs_LR.surf.gii
deform_hum2mac_r=${m2h_repo}/deformation_macaque-human/R.human-to-macaque.sphere.reg.10k_fs_LR.surf.gii

deform_mac2hum_32k_l=${m2h_repo}/deformation_macaque-human/L.macaque-to-human.sphere.reg.32k_fs_LR.surf.gii
deform_mac2hum_32k_r=${m2h_repo}/deformation_macaque-human/R.macaque-to-human.sphere.reg.32k_fs_LR.surf.gii

deform_hum2mac_32k_l=${m2h_repo}/deformation_macaque-human/L.human-to-macaque.sphere.reg.32k_fs_LR.surf.gii
deform_hum2mac_32k_r=${m2h_repo}/deformation_macaque-human/R.human-to-macaque.sphere.reg.32k_fs_LR.surf.gii

######################
## register activation
######################
for con in speech speech_perception speech_production; do

    con_l=${resultpath}/human/${con}_association-test_z_FDR_0.01_m.L.func.gii
    con_r=${resultpath}/human/${con}_association-test_z_FDR_0.01_m.R.func.gii

    # human -> macaque
    wb_command -metric-resample ${con_l} \
                                ${deform_hum2mac_32k_l} \
                                ${macaque_sphere_32k_l} \
                                BARYCENTRIC \
                                ${resultpath}/macaque_registered/${con}_human-to-macaque.L.func.gii
    wb_command -metric-resample ${con_r} \
                                ${deform_hum2mac_32k_r} \
                                ${macaque_sphere_32k_r} \
                                BARYCENTRIC \
                                ${resultpath}/macaque_registered/${con}_human-to-macaque.R.func.gii

    # human -> macaque -> marmoset
    # step1: human 32k -> human 10k
    wb_command -metric-resample ${con_l} \
                                ${human_sphere_32k_l} \
                                ${human_sphere_10k_l} \
                                BARYCENTRIC \
                                ${resultpath}/human/${con}_human.10k.L.func.gii
    wb_command -metric-resample ${con_r} \
                                ${human_sphere_32k_r} \
                                ${human_sphere_10k_r} \
                                BARYCENTRIC \
                                ${resultpath}/human/${con}_human.10k.R.func.gii

    # step2: human 10k -> macaque 10k
    wb_command -metric-resample ${resultpath}/human/${con}_human.10k.L.func.gii \
                                ${deform_hum2mac_l} \
                                ${macaque_sphere_10k_l} \
                                BARYCENTRIC \
                                ${resultpath}/macaque_registered/${con}_human-to-macaque.10k.L.func.gii
    wb_command -metric-resample ${resultpath}/human/${con}_human.10k.R.func.gii \
                                ${deform_hum2mac_r} \
                                ${macaque_sphere_10k_r} \
                                BARYCENTRIC \
                                ${resultpath}/macaque_registered/${con}_human-to-macaque.10k.R.func.gii

    # step3: macaque 10k -> marmoset 10k
    wb_command -metric-resample ${resultpath}/macaque_registered/${con}_human-to-macaque.10k.L.func.gii \
                                ${macaque_sphere_10k_l} \
                                ${deform_mar2mac_l} \
                                BARYCENTRIC \
                                ${resultpath}/marmoset_registered/${con}_human-to-marmoset.10k.L.func.gii
    wb_command -metric-resample ${resultpath}/macaque_registered/${con}_human-to-macaque.10k.R.func.gii \
                                ${macaque_sphere_10k_r} \
                                ${deform_mar2mac_r} \
                                BARYCENTRIC \
                                ${resultpath}/marmoset_registered/${con}_human-to-marmoset.10k.R.func.gii

    # step4: marmsoet 10k -> marmoset 32k
    wb_command -metric-resample ${resultpath}/marmoset_registered/${con}_human-to-marmoset.10k.L.func.gii \
                                ${marmoset_sphere_10k_l} \
                                ${resultpath}/surfFS_matched.L.sphere.surf.gii \
                                BARYCENTRIC \
                                ${resultpath}/marmoset_registered/${con}_human-to-marmoset.L.func.gii
    wb_command -metric-resample ${resultpath}/marmoset_registered/${con}_human-to-marmoset.10k.R.func.gii \
                                ${marmoset_sphere_10k_r} \
                                ${resultpath}/surfFS_matched.R.sphere.surf.gii \
                                BARYCENTRIC \
                                ${resultpath}/marmoset_registered/${con}_human-to-marmoset.R.func.gii
done