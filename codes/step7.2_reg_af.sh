#!/bin/bash

resultpath=/n05dat/yfwang/user/MarmosetWM/result/af_xspecies

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
wb_command -surface-match ${marmoset_sphere_10k_l} ${marmoset_sphere_32k_l} ${resultpath}/surfFS_matched.L.sphere.surf.gii
wb_command -surface-match ${marmoset_sphere_10k_r} ${marmoset_sphere_32k_r} ${resultpath}/surfFS_matched.R.sphere.surf.gii

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


#########################
## register af projection
#########################
# macaque -> human
wb_command -metric-resample ${resultpath}/af_projection/macaque_af_l.func.gii ${deform_mac2hum_32k_l} ${human_sphere_32k_l} BARYCENTRIC ${resultpath}/af_projection_registered/macaque-to-human.af_l.func.gii
wb_command -metric-resample ${resultpath}/af_projection/macaque_af_r.func.gii ${deform_mac2hum_32k_r} ${human_sphere_32k_r} BARYCENTRIC ${resultpath}/af_projection_registered/macaque-to-human.af_r.func.gii

# marmoset -> macaque -> human
wb_command -metric-resample ${resultpath}/af_projection/marmoset_af_l.func.gii \
                            ${resultpath}/surfFS_matched.L.sphere.surf.gii \
                            ${marmoset_sphere_10k_l} \
                            BARYCENTRIC \
                            ${resultpath}/af_projection_registered/marmoset_af_l.10k.func.gii
wb_command -metric-resample ${resultpath}/af_projection/marmoset_af_r.func.gii \
                            ${resultpath}/surfFS_matched.R.sphere.surf.gii \
                            ${marmoset_sphere_10k_r} \
                            BARYCENTRIC \
                            ${resultpath}/af_projection_registered/marmoset_af_r.10k.func.gii

wb_command -metric-resample ${resultpath}/af_projection_registered/marmoset_af_l.10k.func.gii ${deform_mar2mac_l} ${macaque_sphere_10k_l} BARYCENTRIC ${resultpath}/af_projection_registered/marmoset-to-macaque.af_l.10k.func.gii
wb_command -metric-resample ${resultpath}/af_projection_registered/marmoset_af_r.10k.func.gii ${deform_mar2mac_r} ${macaque_sphere_10k_r} BARYCENTRIC ${resultpath}/af_projection_registered/marmoset-to-macaque.af_r.10k.func.gii

wb_command -metric-resample ${resultpath}/af_projection_registered/marmoset-to-macaque.af_l.10k.func.gii ${deform_mac2hum_l} ${human_sphere_10k_l} BARYCENTRIC ${resultpath}/af_projection_registered/marmoset-to-human.af_l.10k.func.gii
wb_command -metric-resample ${resultpath}/af_projection_registered/marmoset-to-macaque.af_r.10k.func.gii ${deform_mac2hum_r} ${human_sphere_10k_r} BARYCENTRIC ${resultpath}/af_projection_registered/marmoset-to-human.af_r.10k.func.gii

wb_command -metric-resample ${resultpath}/af_projection_registered/marmoset-to-human.af_l.10k.func.gii \
                            ${human_sphere_10k_l} \
                            ${human_sphere_32k_l} \
                            BARYCENTRIC \
                            ${resultpath}/af_projection_registered/marmoset-to-human.af_l.32k.func.gii
wb_command -metric-resample ${resultpath}/af_projection_registered/marmoset-to-human.af_r.10k.func.gii \
                            ${human_sphere_10k_r} \
                            ${human_sphere_32k_r} \
                            BARYCENTRIC \
                            ${resultpath}/af_projection_registered/marmoset-to-human.af_r.32k.func.gii
