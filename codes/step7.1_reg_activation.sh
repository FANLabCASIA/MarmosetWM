#!/bin/bash

##########################
## PREPARE activation maps
##########################
datapath=/n05dat/yfwang/user/repo/NeuroSynth_20240423

for con in speech speech_perception speech_production; do

    wb_command -volume-to-surface-mapping ${datapath}/${con}/${con}-test_z_FDR_0.01.nii.gz ${surf_L} /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_association-test_z_FDR_0.01_m.L.func.gii
    wb_command -volume-to-surface-mapping ${datapath}/${con}/${con}-test_z_FDR_0.01.nii.gz ${surf_R} /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_association-test_z_FDR_0.01_m.R.func.gii
done

# use MATLAB
# s_L = gifti('speech_association-test_z_FDR_0.01.L.func.gii');
# s_R = gifti('speech_association-test_z_FDR_0.01.R.func.gii');
# sperc_L = gifti('speech_perception_association-test_z_FDR_0.01.L.func.gii');
# sperc_R = gifti('speech_perception_association-test_z_FDR_0.01.R.func.gii');
# sprod_L = gifti('speech_production_association-test_z_FDR_0.01.L.func.gii');
# sprod_R = gifti('speech_production_association-test_z_FDR_0.01.R.func.gii');

# roi_L = gifti('S1200.L.atlasroi.32k_fs_LR.shape.gii');
# roi_R = gifti('S1200.R.atlasroi.32k_fs_LR.shape.gii');

# s_L.cdata(find(roi_L.cdata==0)) = 0;
# s_R.cdata(find(roi_R.cdata==0)) = 0;
# sperc_L.cdata(find(roi_L.cdata==0)) = 0;
# sperc_R.cdata(find(roi_R.cdata==0)) = 0;
# sprod_L.cdata(find(roi_L.cdata==0)) = 0;
# sprod_R.cdata(find(roi_R.cdata==0)) = 0;

# save(s_L, 'speech_association-test_z_FDR_0.01_m.L.func.gii');
# save(s_R, 'speech_association-test_z_FDR_0.01_m.R.func.gii');
# save(sperc_L, 'speech_perception_association-test_z_FDR_0.01_m.L.func.gii');
# save(sperc_R, 'speech_perception_association-test_z_FDR_0.01_m.R.func.gii');
# save(sprod_L, 'speech_production_association-test_z_FDR_0.01_m.L.func.gii');
# save(sprod_R, 'speech_production_association-test_z_FDR_0.01_m.R.func.gii');

######################
## DO the registration
######################

human_sphere_32k_l=/n05dat/yfwang/user/repo/alignment_macaque-human-main/surfaces/Human/32k_fs_LR/S1200.L.sphere.32k_fs_LR.surf.gii
human_sphere_32k_r=/n05dat/yfwang/user/repo/alignment_macaque-human-main/surfaces/Human/32k_fs_LR/S1200.R.sphere.32k_fs_LR.surf.gii
human_sphere_10k_l=/n05dat/yfwang/user/repo/alignment_macaque-human-main/surfaces/Human/10k_fs_LR/S1200.L.sphere.10k_fs_LR.surf.gii
human_sphere_10k_r=/n05dat/yfwang/user/repo/alignment_macaque-human-main/surfaces/Human/10k_fs_LR/S1200.R.sphere.10k_fs_LR.surf.gii

macaque_sphere_32k_l=/n05dat/yfwang/user/repo/alignment_macaque-human-main/surfaces/Macaque/32k_fs_LR/MacaqueYerkes19.L.sphere.32k_fs_LR.surf.gii
macaque_sphere_32k_r=/n05dat/yfwang/user/repo/alignment_macaque-human-main/surfaces/Macaque/32k_fs_LR/MacaqueYerkes19.R.sphere.32k_fs_LR.surf.gii
macaque_sphere_10k_l=/n05dat/yfwang/user/repo/alignment_macaque-human-main/surfaces/Macaque/10k_fs_LR/MacaqueYerkes19.L.sphere.10k_fs_LR.surf.gii
macaque_sphere_10k_r=/n05dat/yfwang/user/repo/alignment_macaque-human-main/surfaces/Macaque/10k_fs_LR/MacaqueYerkes19.R.sphere.10k_fs_LR.surf.gii

marmoset_sphere_32k_l=/n05dat/yfwang/user/MarmosetWM/support_data/MBM_v3.0.1/surfFS.lh.sphere.surf.gii
marmoset_sphere_32k_r=/n05dat/yfwang/user/MarmosetWM/support_data/MBM_v3.0.1/surfFS.rh.sphere.surf.gii
marmoset_sphere_10k_l=/n05dat/yfwang/user/repo/marmoset-macaque_deformation/MBM_sym_10k_fs_LR/L.sphere.marmoset.10k_fs_LR.surf.gii
marmoset_sphere_10k_r=/n05dat/yfwang/user/repo/marmoset-macaque_deformation/MBM_sym_10k_fs_LR/R.sphere.marmoset.10k_fs_LR.surf.gii

## prepare matched sphere
wb_command -set-structure ${marmoset_sphere_32k_l} CORTEX_LEFT -surface-type SPHERICAL
wb_command -set-structure ${marmoset_sphere_32k_r} CORTEX_RIGHT -surface-type SPHERICAL
wb_command -surface-match ${marmoset_sphere_10k_l} ${marmoset_sphere_32k_l} /n05dat/yfwang/user/MarmosetWM/result/activation/surfFS_matched.L.sphere.surf.gii
wb_command -surface-match ${marmoset_sphere_10k_r} ${marmoset_sphere_32k_r} /n05dat/yfwang/user/MarmosetWM/result/activation/surfFS_matched.R.sphere.surf.gii

## deformation
deform_mar2mac_l=/n05dat/yfwang/user/repo/marmoset-macaque_deformation/deformation/L.marmoset-to-macaque.sphere.reg.10k_fs_LR.surf.gii
deform_mar2mac_r=/n05dat/yfwang/user/repo/marmoset-macaque_deformation/deformation/R.marmoset-to-macaque.sphere.reg.10k_fs_LR.surf.gii

deform_mac2hum_l=/n05dat/yfwang/user/repo/alignment_macaque-human-main/deformation_macaque-human/L.macaque-to-human.sphere.reg.10k_fs_LR.surf.gii
deform_mac2hum_r=/n05dat/yfwang/user/repo/alignment_macaque-human-main/deformation_macaque-human/R.macaque-to-human.sphere.reg.10k_fs_LR.surf.gii

deform_hum2mac_l=/n05dat/yfwang/user/repo/alignment_macaque-human-main/deformation_macaque-human/L.human-to-macaque.sphere.reg.10k_fs_LR.surf.gii
deform_hum2mac_r=/n05dat/yfwang/user/repo/alignment_macaque-human-main/deformation_macaque-human/R.human-to-macaque.sphere.reg.10k_fs_LR.surf.gii

deform_mac2hum_32k_l=/n05dat/yfwang/user/repo/alignment_macaque-human-main/deformation_macaque-human/L.macaque-to-human.sphere.reg.32k_fs_LR.surf.gii
deform_mac2hum_32k_r=/n05dat/yfwang/user/repo/alignment_macaque-human-main/deformation_macaque-human/R.macaque-to-human.sphere.reg.32k_fs_LR.surf.gii

deform_hum2mac_32k_l=/n05dat/yfwang/user/repo/alignment_macaque-human-main/deformation_macaque-human/L.human-to-macaque.sphere.reg.32k_fs_LR.surf.gii
deform_hum2mac_32k_r=/n05dat/yfwang/user/repo/alignment_macaque-human-main/deformation_macaque-human/R.human-to-macaque.sphere.reg.32k_fs_LR.surf.gii

######################
## register activation
######################
# human -> macaque -> marmoset
for con in speech speech_perception speech_production; do

    con_l=/n05dat/yfwang/user/MarmosetWM/result/activation/${con}_association-test_z_FDR_0.01_m.L.func.gii
    con_r=/n05dat/yfwang/user/MarmosetWM/result/activation/${con}_association-test_z_FDR_0.01_m.R.func.gii
    
    wb_command -metric-resample ${con_l} \
                                ${human_sphere_32k_l} \
                                ${human_sphere_10k_l} \
                                BARYCENTRIC \
                                /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human.10k.L.func.gii
    wb_command -metric-resample ${con_r} \
                                ${human_sphere_32k_r} \
                                ${human_sphere_10k_r} \
                                BARYCENTRIC \
                                /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human.10k.R.func.gii

    wb_command -metric-resample /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human.10k.L.func.gii ${deform_hum2mac_l} ${macaque_sphere_10k_l} BARYCENTRIC /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human-to-macaque.10k.L.func.gii
    wb_command -metric-resample /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human.10k.R.func.gii ${deform_hum2mac_r} ${macaque_sphere_10k_r} BARYCENTRIC /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human-to-macaque.10k.R.func.gii

    wb_command -metric-resample /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human-to-macaque.10k.L.func.gii ${macaque_sphere_10k_l} ${deform_mar2mac_l} BARYCENTRIC /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human-to-marmoset.10k.L.func.gii
    wb_command -metric-resample /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human-to-macaque.10k.R.func.gii ${macaque_sphere_10k_r} ${deform_mar2mac_r} BARYCENTRIC /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human-to-marmoset.10k.R.func.gii

    wb_command -metric-resample /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human-to-marmoset.10k.L.func.gii \
                                ${marmoset_sphere_10k_l} \
                                /n05dat/yfwang/user/MarmosetWM/result/activation/surfFS_matched.L.sphere.surf.gii \
                                BARYCENTRIC \
                                /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human-to-marmoset.L.func.gii
    wb_command -metric-resample /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human-to-marmoset.10k.R.func.gii \
                                ${marmoset_sphere_10k_r} \
                                /n05dat/yfwang/user/MarmosetWM/result/activation/surfFS_matched.R.sphere.surf.gii \
                                BARYCENTRIC \
                                /n05dat/yfwang/user/MarmosetWM/result/activation/${con}_human-to-marmoset.R.func.gii
done



