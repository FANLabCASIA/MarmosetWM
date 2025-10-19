#!/bin/bash

resultpath=/gpfs/userdata/yfwang/MarmosetWM/result/af_projection_registration

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

## myelin
human_myelin_32k_l=/gpfs/userdata/yfwang/MarmosetWM/result/af_xspecies_by_myelin/registration/data/myelin/human/human_myelin_L.func.gii
human_myelin_32k_r=/gpfs/userdata/yfwang/MarmosetWM/result/af_xspecies_by_myelin/registration/data/myelin/human/human_myelin_R.func.gii
macaque_myelin_32k_l=/gpfs/userdata/yfwang/MarmosetWM/result/af_xspecies_by_myelin/registration/data/myelin/macaque/macaque_myelin_L.func.gii
macaque_myelin_32k_r=/gpfs/userdata/yfwang/MarmosetWM/result/af_xspecies_by_myelin/registration/data/myelin/macaque/macaque_myelin_R.func.gii
marmoset_myelin_32k_l=/gpfs/userdata/yfwang/MarmosetWM/result/af_xspecies_by_myelin/registration/data/myelin/marmoset/marmoset_myelin_L.func.gii
marmoset_myelin_32k_r=/gpfs/userdata/yfwang/MarmosetWM/result/af_xspecies_by_myelin/registration/data/myelin/marmoset/marmoset_myelin_R.func.gii


#################################################
## register myelin (marmoset -> macaque -> human)
#################################################
## macaque -> human
wb_command -metric-resample ${macaque_myelin_32k_l} \
                            ${deform_mac2hum_32k_l} \
                            ${human_sphere_32k_l} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/macaque-to-human.myelin_l.32k.func.gii
wb_command -metric-resample ${macaque_myelin_32k_r} \
                            ${deform_mac2hum_32k_r} \
                            ${human_sphere_32k_r} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/macaque-to-human.myelin_r.32k.func.gii

## marmoset -> macaque -> human
# step1: marmoset 32k -> marmoset 10k
wb_command -metric-resample ${marmoset_myelin_32k_l} \
                            ${resultpath}/surfFS_matched.L.sphere.surf.gii \
                            ${marmoset_sphere_10k_l} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/marmoset_myelin_l.10k.func.gii
wb_command -metric-resample ${marmoset_myelin_32k_r} \
                            ${resultpath}/surfFS_matched.R.sphere.surf.gii \
                            ${marmoset_sphere_10k_r} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/marmoset_myelin_r.10k.func.gii

# step2: marmoset 10k -> macaque 10k
wb_command -metric-resample ${resultpath}/myelin_registration/mmh/marmoset_myelin_l.10k.func.gii \
                            ${deform_mar2mac_l} \
                            ${macaque_sphere_10k_l} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/marmoset-to-macaque.myelin_l.10k.func.gii
wb_command -metric-resample ${resultpath}/myelin_registration/mmh/marmoset_myelin_r.10k.func.gii \
                            ${deform_mar2mac_r} \
                            ${macaque_sphere_10k_r} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/marmoset-to-macaque.myelin_r.10k.func.gii

# step3: macaque 10k -> human 10k
wb_command -metric-resample ${resultpath}/myelin_registration/mmh/marmoset-to-macaque.myelin_l.10k.func.gii \
                            ${deform_mac2hum_l} \
                            ${human_sphere_10k_l} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/marmoset-to-human.myelin_l.10k.func.gii
wb_command -metric-resample ${resultpath}/myelin_registration/mmh/marmoset-to-macaque.myelin_r.10k.func.gii \
                            ${deform_mac2hum_r} \
                            ${human_sphere_10k_r} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/marmoset-to-human.myelin_r.10k.func.gii

# (For visualization) macaque 10k -> macaque 32k
wb_command -metric-resample ${resultpath}/myelin_registration/mmh/marmoset-to-macaque.myelin_l.10k.func.gii \
                            ${human_sphere_10k_l} \
                            ${human_sphere_32k_l} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/marmoset-to-macaque.myelin_l.32k.func.gii
wb_command -metric-resample ${resultpath}/myelin_registration/mmh/marmoset-to-macaque.myelin_r.10k.func.gii \
                            ${human_sphere_10k_r} \
                            ${human_sphere_32k_r} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/marmoset-to-macaque.myelin_r.32k.func.gii

# step4: human 10k -> human 32k
wb_command -metric-resample ${resultpath}/myelin_registration/mmh/marmoset-to-human.myelin_l.10k.func.gii \
                            ${human_sphere_10k_l} \
                            ${human_sphere_32k_l} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/marmoset-to-human.myelin_l.32k.func.gii
wb_command -metric-resample ${resultpath}/myelin_registration/mmh/marmoset-to-human.myelin_r.10k.func.gii \
                            ${human_sphere_10k_r} \
                            ${human_sphere_32k_r} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/mmh/marmoset-to-human.myelin_r.32k.func.gii

#################################################
## register myelin (human -> macaque -> marmoset)
#################################################
## human -> macaque
wb_command -metric-resample ${human_myelin_32k_l} \
                            ${deform_hum2mac_32k_l} \
                            ${macaque_sphere_32k_l} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/hmm/human-to-macaque.myelin_l.32k.func.gii
wb_command -metric-resample ${human_myelin_32k_r} \
                            ${deform_hum2mac_32k_r} \
                            ${macaque_sphere_32k_r} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/hmm/human-to-macaque.myelin_r.32k.func.gii

## human ->  macaque -> marmoset
# step1: human 32k -> human 10k
wb_command -metric-resample ${human_myelin_32k_l} \
                            ${human_sphere_32k_l} \
                            ${human_sphere_10k_l} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/hmm/human_myelin_l.10k.func.gii
wb_command -metric-resample ${human_myelin_32k_r} \
                            ${human_sphere_32k_r} \
                            ${human_sphere_10k_r} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/hmm/human_myelin_r.10k.func.gii

# step2: human 10k -> macaque 10k
wb_command -metric-resample ${resultpath}/myelin_registration/hmm/human_myelin_l.10k.func.gii \
                            ${deform_hum2mac_l} \
                            ${macaque_sphere_10k_l} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/hmm/human-to-macaque.myelin_l.10k.func.gii
wb_command -metric-resample ${resultpath}/myelin_registration/hmm/human_myelin_r.10k.func.gii \
                            ${deform_hum2mac_r} \
                            ${macaque_sphere_10k_r} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/hmm/human-to-macaque.myelin_r.10k.func.gii

# step3: macaque 10k -> marmoset 10k
wb_command -metric-resample ${resultpath}/myelin_registration/hmm/human-to-macaque.myelin_l.10k.func.gii \
                            ${macaque_sphere_10k_l} \
                            ${deform_mar2mac_l} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/hmm/human-to-marmoset.myelin_l.10k.func.gii
wb_command -metric-resample ${resultpath}/myelin_registration/hmm/human-to-macaque.myelin_r.10k.func.gii \
                            ${macaque_sphere_10k_r} \
                            ${deform_mar2mac_r} \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/hmm/human-to-marmoset.myelin_r.10k.func.gii

# step4: marmoset 10k -> marmoset 32k
wb_command -metric-resample ${resultpath}/myelin_registration/hmm/human-to-marmoset.myelin_l.10k.func.gii \
                            ${marmoset_sphere_10k_l} \
                            ${resultpath}/surfFS_matched.L.sphere.surf.gii \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/hmm/human-to-marmoset.myelin_l.32k.func.gii
wb_command -metric-resample ${resultpath}/myelin_registration/hmm/human-to-marmoset.myelin_r.10k.func.gii \
                            ${marmoset_sphere_10k_r} \
                            ${resultpath}/surfFS_matched.R.sphere.surf.gii \
                            BARYCENTRIC \
                            ${resultpath}/myelin_registration/hmm/human-to-marmoset.myelin_r.32k.func.gii
