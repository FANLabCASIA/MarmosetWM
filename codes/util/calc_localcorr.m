addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI'));
addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/NIFTI'));

resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/af_projection_registration/';

subs_human = textread('/gpfs/userdata/yfwang/preprocess_fsl/human/humanlist40.txt', '%s');
subs_macaque = textread('/gpfs/userdata/yfwang/preprocess_fsl/macaque_tvb/macaque_tvb_list.txt', '%s');
subs_marmoset = textread('/gpfs/userdata/yfwang/MarmosetWM/support_data/marmoset_MBM_list.txt', '%s');

atlas_l = gifti('/gpfs/userdata/yfwang/MarmosetWM/support_data/atlas/human/fsaverage.L.BN_Atlas.32k_fs_LR.label.gii');
atlas_r = gifti('/gpfs/userdata/yfwang/MarmosetWM/support_data/atlas/human/fsaverage.R.BN_Atlas.32k_fs_LR.label.gii');

sphere_l = gifti('/gpfs/userdata/yfwang/MarmosetWM/result/af_xspecies_by_myelin/registration/data/surface/human/L.sphere.32k_fs_LR.surf.gii');
sphere_r = gifti('/gpfs/userdata/yfwang/MarmosetWM/result/af_xspecies_by_myelin/registration/data/surface/human/R.sphere.32k_fs_LR.surf.gii');

temp_l = gifti('/gpfs/userdata/yfwang/MarmosetWM/support_data/atlas/human/100307.L.atlasroi.32k_fs_LR.shape.gii');
temp_r = gifti('/gpfs/userdata/yfwang/MarmosetWM/support_data/atlas/human/100307.R.atlasroi.32k_fs_LR.shape.gii');


%% human vs macaque
localcorr_human_macaque_l = gifti('/gpfs/userdata/yfwang/MarmosetWM/support_data/atlas/human/100307.L.atlasroi.32k_fs_LR.shape.gii');
localcorr_human_macaque_r = gifti('/gpfs/userdata/yfwang/MarmosetWM/support_data/atlas/human/100307.R.atlasroi.32k_fs_LR.shape.gii');

localcorr_human_macaque_l.cdata = zeros(size(localcorr_human_macaque_l.cdata));
localcorr_human_macaque_r.cdata = zeros(size(localcorr_human_macaque_r.cdata));

localcorr_human_macaque_A45c_l = zeros(length(subs_human), length(subs_macaque), size(find(atlas_l.cdata==33),1));
localcorr_human_macaque_A45c_r = zeros(length(subs_human), length(subs_macaque), size(find(atlas_r.cdata==34),1));

for h=1:length(subs_human)
    for m=1:length(subs_macaque)

        disp(strcat(subs_human{h}, '-', subs_macaque{m}));

        af_human_l = gifti(strcat(resultpath, 'af_projection_registered_indi/human/', subs_human{h}, '/', subs_human{h}, '_af_l_thr0_norm_thres.func.gii'));
        af_human_r = gifti(strcat(resultpath, 'af_projection_registered_indi/human/', subs_human{h}, '/', subs_human{h}, '_af_r_thr0_norm_thres.func.gii'));

        af_macaque_l = gifti(strcat(resultpath, 'af_projection_registered_indi/macaque_tvb/', subs_macaque{m}, '/', subs_macaque{m}, '-human_af_l_thr0_norm_thres.func.gii'));
        af_macaque_r = gifti(strcat(resultpath, 'af_projection_registered_indi/macaque_tvb/', subs_macaque{m}, '/', subs_macaque{m}, '-human_af_r_thr0_norm_thres.func.gii'));

        temp_l.cdata = zeros(size(temp_l.cdata));
        temp_l.cdata = surflocalcorr(af_human_l.cdata, af_macaque_l.cdata, sphere_l, 40);
        temp_l.cdata = temp_l.cdata .* af_human_l.cdata .* af_macaque_l.cdata;

        temp_r.cdata = zeros(size(temp_r.cdata));
        temp_r.cdata = surflocalcorr(af_human_r.cdata, af_macaque_r.cdata, sphere_r, 40);
        temp_r.cdata = temp_r.cdata .* af_human_r.cdata .* af_macaque_r.cdata;

        save(temp_l, strcat(resultpath, 'af_projection_registered_indi_localcorr/human_nhp/', subs_human{h}, '/', subs_human{h}, '-', subs_macaque{m}, '_af_l_localcorr_40_weighted.func.gii'));
        save(temp_r, strcat(resultpath, 'af_projection_registered_indi_localcorr/human_nhp/', subs_human{h}, '/', subs_human{h}, '-', subs_macaque{m}, '_af_r_localcorr_40_weighted.func.gii'));

        localcorr_human_macaque_l.cdata = localcorr_human_macaque_l.cdata + temp_l.cdata;
        localcorr_human_macaque_r.cdata = localcorr_human_macaque_r.cdata + temp_r.cdata;

        localcorr_human_macaque_A45c_l(h, m, :) = temp_l.cdata(find(atlas_l.cdata==33));
        localcorr_human_macaque_A45c_r(h, m, :) = temp_r.cdata(find(atlas_r.cdata==34));
    end
end

localcorr_human_macaque_l.cdata = localcorr_human_macaque_l.cdata ./ length(subs_human) ./ length(subs_macaque);
localcorr_human_macaque_r.cdata = localcorr_human_macaque_r.cdata ./ length(subs_human) ./ length(subs_macaque);

save(localcorr_human_macaque_l, strcat(resultpath, 'af_projection_registered_indi_localcorr/localcorr_human_macaque_l_40_weighted.func.gii'));
save(localcorr_human_macaque_r, strcat(resultpath, 'af_projection_registered_indi_localcorr/localcorr_human_macaque_r_40_weighted.func.gii'));

save(strcat(resultpath, 'af_projection_registered_indi_localcorr/localcorr_human_macaque_l_40_weighted_A45c.mat'), localcorr_human_macaque_A45c_l);
save(strcat(resultpath, 'af_projection_registered_indi_localcorr/localcorr_human_macaque_r_40_weighted_A45c.mat'), localcorr_human_macaque_A45c_r);


%% human vs marmoset
localcorr_human_marmoset_l = gifti('/gpfs/userdata/yfwang/MarmosetWM/support_data/atlas/human/100307.L.atlasroi.32k_fs_LR.shape.gii');
localcorr_human_marmoset_r = gifti('/gpfs/userdata/yfwang/MarmosetWM/support_data/atlas/human/100307.R.atlasroi.32k_fs_LR.shape.gii');

localcorr_human_marmoset_l.cdata = zeros(size(localcorr_human_marmoset_l.cdata));
localcorr_human_marmoset_r.cdata = zeros(size(localcorr_human_marmoset_r.cdata));

localcorr_human_marmoset_A45c_l = zeros(length(subs_human), length(subs_marmoset), size(find(atlas_l.cdata==33),1));
localcorr_human_marmoset_A45c_r = zeros(length(subs_human), length(subs_marmoset), size(find(atlas_r.cdata==34),1));

for h=1:length(subs_human)
    for m=1:length(subs_marmoset)

        disp(strcat(subs_human{h}, '-', subs_marmoset{m}));

        af_human_l = gifti(strcat(resultpath, 'af_projection_registered_indi/human/', subs_human{h}, '/', subs_human{h}, '_af_l_thr0_norm_thres.func.gii'));
        af_human_r = gifti(strcat(resultpath, 'af_projection_registered_indi/human/', subs_human{h}, '/', subs_human{h}, '_af_r_thr0_norm_thres.func.gii'));

        af_marmoset_l = gifti(strcat(resultpath, 'af_projection_registered_indi/marmoset_MBM/', subs_marmoset{m}, '/', subs_marmoset{m}, '-human_af_l_thr0_norm_thres.func.gii'));
        af_marmoset_r = gifti(strcat(resultpath, 'af_projection_registered_indi/marmoset_MBM/', subs_marmoset{m}, '/', subs_marmoset{m}, '-human_af_r_thr0_norm_thres.func.gii'));

        temp_l.cdata = zeros(size(temp_l.cdata));
        temp_l.cdata = surflocalcorr(af_human_l.cdata, af_marmoset_l.cdata, sphere_l, 40);
        temp_l.cdata = temp_l.cdata .* af_human_l.cdata .* af_marmoset_l.cdata;

        temp_r.cdata = zeros(size(temp_r.cdata));
        temp_r.cdata = surflocalcorr(af_human_r.cdata, af_marmoset_r.cdata, sphere_r, 40);
        temp_r.cdata = temp_r.cdata .* af_human_r.cdata .* af_marmoset_r.cdata;

        save(temp_l, strcat(resultpath, 'af_projection_registered_indi_localcorr/human_nhp/', subs_human{h}, '/', subs_human{h}, '-', subs_marmoset{m}, '_af_l_localcorr_40_weighted.func.gii'));
        save(temp_r, strcat(resultpath, 'af_projection_registered_indi_localcorr/human_nhp/', subs_human{h}, '/', subs_human{h}, '-', subs_marmoset{m}, '_af_r_localcorr_40_weighted.func.gii'));

        localcorr_human_marmoset_l.cdata = localcorr_human_marmoset_l.cdata + temp_l.cdata;
        localcorr_human_marmoset_r.cdata = localcorr_human_marmoset_r.cdata + temp_r.cdata;

        localcorr_human_marmoset_A45c_l(h, m, :) = temp_l.cdata(find(atlas_l.cdata==33));
        localcorr_human_marmoset_A45c_r(h, m, :) = temp_r.cdata(find(atlas_r.cdata==34));
    end
end

localcorr_human_marmoset_l.cdata = localcorr_human_marmoset_l.cdata ./ length(subs_human) ./ length(subs_marmoset);
localcorr_human_marmoset_r.cdata = localcorr_human_marmoset_r.cdata ./ length(subs_human) ./ length(subs_marmoset);

save(localcorr_human_marmoset_l, strcat(resultpath, 'af_projection_registered_indi_localcorr/localcorr_human_marmoset_l_40_weighted.func.gii'));
save(localcorr_human_marmoset_r, strcat(resultpath, 'af_projection_registered_indi_localcorr/localcorr_human_marmoset_r_40_weighted.func.gii'));

save(strcat(resultpath, 'af_projection_registered_indi_localcorr/localcorr_human_marmoset_l_40_weighted_A45c.mat'), localcorr_human_marmoset_A45c_l);
save(strcat(resultpath, 'af_projection_registered_indi_localcorr/localcorr_human_marmoset_r_40_weighted_A45c.mat'), localcorr_human_marmoset_A45c_r);