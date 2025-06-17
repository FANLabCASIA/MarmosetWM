addpath('/n02dat01/users/yfwang/software/MatlabToolbox/GIFTI/');

resultpath = '/n02dat01/users/yfwang/MarmosetWM/result/bp_xspecies/';

%% load data
c2h_l = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas.L.func.gii'));
c2h_r = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas.R.func.gii'));
mac2h_l = gifti(strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas.L.func.gii'));
mac2h_r = gifti(strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas.R.func.gii'));
mar2h_l = gifti(strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas.L.func.gii'));
mar2h_r = gifti(strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas.R.func.gii'));

temp_l = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas.L.func.gii'));
temp_r = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas.R.func.gii'));


%% normalize
c2h_l.cdata = c2h_l.cdata ./ max(c2h_l.cdata);
c2h_r.cdata = c2h_r.cdata ./ max(c2h_r.cdata);
save(c2h_l, strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas_maxnorm.L.func.gii'));
save(c2h_r, strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas_maxnorm.R.func.gii'));

mac2h_l.cdata = mac2h_l.cdata ./ max(mac2h_l.cdata);
mac2h_r.cdata = mac2h_r.cdata ./ max(mac2h_r.cdata);
save(mac2h_l, strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas_maxnorm.L.func.gii'));
save(mac2h_r, strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas_maxnorm.R.func.gii'));

mar2h_l.cdata = mar2h_l.cdata ./ max(mar2h_l.cdata);
mar2h_r.cdata = mar2h_r.cdata ./ max(mar2h_r.cdata);
save(mar2h_l, strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas_maxnorm.L.func.gii'));
save(mar2h_r, strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas_maxnorm.R.func.gii'));


%% 3/4 species union (normalize)
c2h_l = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas_maxnorm.L.func.gii'));
c2h_r = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas_maxnorm.R.func.gii'));
mac2h_l = gifti(strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas_maxnorm.L.func.gii'));
mac2h_r = gifti(strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas_maxnorm.R.func.gii'));
mar2h_l = gifti(strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas_maxnorm.L.func.gii'));
mar2h_r = gifti(strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas_maxnorm.R.func.gii'));

temp_l.cdata = c2h_l.cdata .* mac2h_l.cdata;
temp_r.cdata = c2h_r.cdata .* mac2h_r.cdata;
save(temp_l, strcat(resultpath, 'multispecies/union/human_chimp_macaque_norm.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/union/human_chimp_macaque_norm.R.func.gii'));

temp_l.cdata = c2h_l.cdata .* mac2h_l.cdata .* mar2h_l.cdata;
temp_r.cdata = c2h_r.cdata .* mac2h_r.cdata .* mar2h_r.cdata;
save(temp_l, strcat(resultpath, 'multispecies/union/human_chimp_macaque_marmoset_norm.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/union/human_chimp_macaque_marmoset_norm.R.func.gii'));


%% 3/4 species union (no-normalize)
c2h_l = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas.L.func.gii'));
c2h_r = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas.R.func.gii'));
mac2h_l = gifti(strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas.L.func.gii'));
mac2h_r = gifti(strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas.R.func.gii'));
mar2h_l = gifti(strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas.L.func.gii'));
mar2h_r = gifti(strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas.R.func.gii'));

temp_l.cdata = c2h_l.cdata .* mac2h_l.cdata;
temp_r.cdata = c2h_r.cdata .* mac2h_r.cdata;
save(temp_l, strcat(resultpath, 'multispecies/union/human_chimp_macaque_nonorm.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/union/human_chimp_macaque_nonorm.R.func.gii'));

temp_l.cdata = c2h_l.cdata .* mac2h_l.cdata .* mar2h_l.cdata;
temp_r.cdata = c2h_r.cdata .* mac2h_r.cdata .* mar2h_r.cdata;
save(temp_l, strcat(resultpath, 'multispecies/union/human_chimp_macaque_marmoset_nonorm.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/union/human_chimp_macaque_marmoset_nonorm.R.func.gii'));


%% 3 species xor (normalize)
c2h_l = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas_maxnorm.L.func.gii'));
c2h_r = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas_maxnorm.R.func.gii'));
mac2h_l = gifti(strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas_maxnorm.L.func.gii'));
mac2h_r = gifti(strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas_maxnorm.R.func.gii'));

temp_l.cdata = mac2h_l.cdata - mac2h_l.cdata .* c2h_l.cdata * 0.9999;
temp_r.cdata = mac2h_r.cdata - mac2h_r.cdata .* c2h_r.cdata * 0.9999;
save(temp_l, strcat(resultpath, 'multispecies/xor/3species/human_chimp_2_macaque.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/xor/3species/human_chimp_2_macaque.R.func.gii'));

temp_l.cdata = mac2h_l.cdata .* c2h_l.cdata;
temp_r.cdata = mac2h_r.cdata .* c2h_r.cdata;
save(temp_l, strcat(resultpath, 'multispecies/xor/3species/human_2_chimp_macaque.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/xor/3species/human_2_chimp_macaque.R.func.gii'));


%% 4 species xor (normalize)
c2h_l = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas_maxnorm.L.func.gii'));
c2h_r = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas_maxnorm.R.func.gii'));
mac2h_l = gifti(strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas_maxnorm.L.func.gii'));
mac2h_r = gifti(strcat(resultpath, 'roi_wise/mac2h_minKL_on_human_atlas_maxnorm.R.func.gii'));
mar2h_l = gifti(strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas_maxnorm.L.func.gii'));
mar2h_r = gifti(strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas_maxnorm.R.func.gii'));

temp_l.cdata = mar2h_l.cdata - mar2h_l.cdata .* mac2h_l.cdata * 0.9999;
temp_r.cdata = mar2h_r.cdata - mar2h_r.cdata .* mac2h_r.cdata * 0.9999;
save(temp_l, strcat(resultpath, 'multispecies/xor/4species/human_chimp_macaque_2_marmoset.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/xor/4species/human_chimp_macaque_2_marmoset.R.func.gii'));

temp_l.cdata = mar2h_l.cdata .* mac2h_l.cdata - mar2h_l.cdata .* mac2h_l.cdata .* c2h_l.cdata * 0.9999;
temp_r.cdata = mar2h_r.cdata .* mac2h_r.cdata - mar2h_r.cdata .* mac2h_r.cdata .* c2h_r.cdata * 0.9999;
save(temp_l, strcat(resultpath, 'multispecies/xor/4species/human_chimp_2_macaque_marmoset.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/xor/4species/human_chimp_2_macaque_marmoset.R.func.gii'));

temp_l.cdata = mar2h_l.cdata .* mac2h_l.cdata .* c2h_l.cdata;
temp_r.cdata = mar2h_r.cdata .* mac2h_r.cdata .* c2h_r.cdata;
save(temp_l, strcat(resultpath, 'multispecies/xor/4species/human_2_chimp_macaque_marmoset.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/xor/4species/human_2_chimp_macaque_marmoset.R.func.gii'));


%% 3/4 species union (for the same bar)
temp_l = gifti(strcat(resultpath, 'multispecies/union/human_chimp_macaque_marmoset_nonorm.L.func.gii');
temp_r = gifti(strcat(resultpath, 'multispecies/union/human_chimp_macaque_marmoset_nonorm.R.func.gii');
max_l = max(temp_l.cdata);
max_r = max(temp_r.cdata);
temp_l.cdata(20650) = max_l;
temp_r.cdata(20650) = max_r;
save(temp_l, strcat(resultpath, 'multispecies/union/human_chimp_macaque_marmoset_bar.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/union/human_chimp_macaque_marmoset_bar.R.func.gii'));

temp_l = gifti(strcat(resultpath, 'multispecies/union/human_chimp_macaque_nonorm.L.func.gii'));
temp_r = gifti(strcat(resultpath, 'multispecies/union/human_chimp_macaque_nonorm.R.func.gii'));
temp_l.cdata(20650) = max_l;
temp_r.cdata(20650) = max_r;
save(temp_l, strcat(resultpath, 'multispecies/union/human_chimp_macaque_bar.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/union/human_chimp_macaque_bar.R.func.gii'));

temp_l = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas.L.func.gii'));
temp_r = gifti(strcat(resultpath, 'roi_wise/c2h_minKL_on_human_atlas.R.func.gii'));
temp_l.cdata(20650) = max_l;
temp_r.cdata(20650) = max_r;
save(temp_l, strcat(resultpath, 'multispecies/union/human_chimp_bar.L.func.gii'));
save(temp_r, strcat(resultpath, 'multispecies/union/human_chimp_bar.R.func.gii'));
