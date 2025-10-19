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


#########################
## register af projection
#########################

## human
matlab -nodisplay -nosplash -r "thres_af_human; exit"

## macaque -> human
matlab -nodisplay -nosplash -r "thres_af_macaque; exit"

for sub in `cat /gpfs/userdata/yfwang/preprocess_fsl/macaque_tvb/macaque_tvb_list.txt`; do

    echo $sub
    subdir=${resultpath}/af_projection_registration_indi/macaque_tvb/${sub}

    wb_command -metric-resample ${subdir}/${sub}_af_l_thr0_norm_thres.func.gii \
                                ${deform_mac2hum_32k_l} \
                                ${human_sphere_32k_l} \
                                BARYCENTRIC \
                                ${subdir}/${sub}-human_af_l_thr0_norm_thres.func.gii
                                
    wb_command -metric-resample ${subdir}/${sub}_af_r_thr0_norm_thres.func.gii \
                                ${deform_mac2hum_32k_r} \
                                ${human_sphere_32k_r} \
                                BARYCENTRIC \
                                ${subdir}/${sub}-human_af_r_thr0_norm_thres.func.gii
done

## marmoset -> macaque -> human
matlab -nodisplay -nosplash -r "thres_af_marmoset; exit"

for sub in `cat /gpfs/userdata/yfwang/MarmosetWM/support_data/marmoset_MBM_list.txt`; do

    echo $sub
    subdir=${resultpath}/af_projection_registration_indi/marmoset_MBM/${sub}

    # downsample marmoset af projection from 32k to 10k
    wb_command -metric-resample ${subdir}/${sub}_af_l_thr0_norm_thres.func.gii \
                                ${resultpath}/surfFS_matched.L.sphere.surf.gii \
                                ${marmoset_sphere_10k_l} \
                                BARYCENTRIC \
                                ${subdir}/${sub}_af_l_thr0_norm_thres.10k.func.gii
    wb_command -metric-resample ${subdir}/${sub}_af_r_thr0_norm_thres.func.gii \
                                ${resultpath}/surfFS_matched.R.sphere.surf.gii \
                                ${marmoset_sphere_10k_r} \
                                BARYCENTRIC \
                                ${subdir}/${sub}_af_r_thr0_norm_thres.10k.func.gii

    # register marmoset af projection 10k to macaque 10k
    wb_command -metric-resample ${subdir}/${sub}_af_l_thr0_norm_thres.10k.func.gii \
                                ${deform_mar2mac_l} \
                                ${macaque_sphere_10k_l} \
                                BARYCENTRIC \
                                ${subdir}/${sub}-macaque_af_l_thr0_norm_thres.10k.func.gii
    wb_command -metric-resample ${subdir}/${sub}_af_r_thr0_norm_thres.10k.func.gii \
                                ${deform_mar2mac_r} \
                                ${macaque_sphere_10k_r} \
                                BARYCENTRIC \
                                ${subdir}/${sub}-macaque_af_r_thr0_norm_thres.10k.func.gii

    # register macaque af projection 10k to human 10k
    wb_command -metric-resample ${subdir}/${sub}-macaque_af_l_thr0_norm_thres.10k.func.gii \
                                ${deform_mac2hum_l} \
                                ${human_sphere_10k_l} \
                                BARYCENTRIC \
                                ${subdir}/${sub}-human_af_l_thr0_norm_thres.10k.func.gii
    wb_command -metric-resample ${subdir}/${sub}-macaque_af_r_thr0_norm_thres.10k.func.gii \
                                ${deform_mac2hum_r} \
                                ${human_sphere_10k_r} \
                                BARYCENTRIC \
                                ${subdir}/${sub}-human_af_r_thr0_norm_thres.10k.func.gii

    # upsample human af projection from 10k to 32k
    wb_command -metric-resample ${subdir}/${sub}-human_af_l_thr0_norm_thres.10k.func.gii \
                                ${human_sphere_10k_l} \
                                ${human_sphere_32k_l} \
                                BARYCENTRIC \
                                ${subdir}/${sub}-human_af_l_thr0_norm_thres.func.gii
    wb_command -metric-resample ${subdir}/${sub}-human_af_r_thr0_norm_thres.10k.func.gii \
                                ${human_sphere_10k_r} \
                                ${human_sphere_32k_r} \
                                BARYCENTRIC \
                                ${subdir}/${sub}-human_af_r_thr0_norm_thres.func.gii
done
