addpath('/n02dat01/users/yfwang/software/MatlabToolbox/CIFTI/');
addpath('/n02dat01/users/yfwang/software/MatlabToolbox/GIFTI/');
addpath('/n02dat01/users/yfwang/repo/comparing-connectivity-blueprints-master/code/');
addpath('/n02dat01/users/yfwang/software/MatlabToolbox/spm12/toolbox/brant/brant_postprocess/brant_STAT');

% fibers = ['AC', 'AF', 'AR', 'ATR', 'CBD', 'CBP', 'CBT', 'CST', 'FA',   'FX',   'IFOF', 'ILF',   'MDLF', 'OR', 'PTR', 'SLF1', 'SLF2', 'SLF3', 'STR', 'UF', 'VOF', 'FMA', 'FMI', 'MCP']
fiber_index_l = [1,3,5,7,9,11,13,15,17,21,42,44,24,26,28,30,32,34,36,38,40,19,20,23];
fiber_index_r = [2,4,6,8,10,12,14,16,18,22,43,45,25,27,29,31,33,35,37,39,41,19,20,23];

% initialize the datapath
humandatapath='/n02dat01/users/yfwang/Data/preprocess_fsl/human/HCP_40/';
marmosetdatapath='/n02dat01/users/yfwang/MarmosetWM/result/xtract_result_v1.1_MBM/';

% load cerebral roi
hroi_l_file = gifti(strcat(humandatapath,'100307.L.atlasroi.32k_fs_LR.shape.gii'));
hroi_r_file = gifti(strcat(humandatapath,'100307.R.atlasroi.32k_fs_LR.shape.gii'));
indexh_l = find(hroi_l_file.cdata>0);
indexh_r = find(hroi_r_file.cdata>0);

mroi_l_file = gifti('/n02dat01/users/yfwang/MarmosetWM/support_data/MBM_v3.0.1/surfFS.lh.atlasroi.shape.gii');
mroi_r_file = gifti('/n02dat01/users/yfwang/MarmosetWM/support_data/MBM_v3.0.1/surfFS.rh.atlasroi.shape.gii');
indexm_l = find(mroi_l_file.cdata>0);
indexm_r = find(mroi_r_file.cdata>0);

temp_human_l = gifti(strcat(humandatapath,'100307.L.atlasroi.32k_fs_LR.shape.gii'));
temp_human_r = gifti(strcat(humandatapath,'100307.R.atlasroi.32k_fs_LR.shape.gii'));
temp_marmoset_l = gifti('/n02dat01/users/yfwang/MarmosetWM/support_data/MBM_v3.0.1/surfFS.lh.atlasroi.shape.gii');
temp_marmoset_r = gifti('/n02dat01/users/yfwang/MarmosetWM/support_data/MBM_v3.0.1/surfFS.rh.atlasroi.shape.gii');

resultpath='/n02dat01/users/yfwang/MarmosetWM/result/bp_xspecies/';

%%%%%%%%%%%%
% roi-wise %
%%%%%%%%%%%%

% load atlas
atlas_human_l = gifti('/n02dat01/users/yfwang/software/BN_Atlas_freesurfer/fsaverage/fsaverage_LR32k/fsaverage.L.BN_Atlas.32k_fs_LR.label.gii');
atlas_human_r = gifti('/n02dat01/users/yfwang/software/BN_Atlas_freesurfer/fsaverage/fsaverage_LR32k/fsaverage.R.BN_Atlas.32k_fs_LR.label.gii');
atlas_marmoset_l = gifti('/n02dat01/users/yfwang/MarmosetWM/support_data/MBM_v3.0.1/surfFS.lh.MBM_cortex_vH.label.gii');
atlas_marmoset_r = gifti('/n02dat01/users/yfwang/MarmosetWM/support_data/MBM_v3.0.1/surfFS.rh.MBM_cortex_vH.label.gii');

% load blueprint
bp_human_l = load(strcat(humandatapath, 'group40/human40_BP_atlas.L.mat'));
bp_human_r = load(strcat(humandatapath, 'group40/human40_BP_atlas.R.mat'));
bp_marmoset_l = load(strcat(marmosetdatapath, 'group24_blueprint/marmoset24_BP_atlas.L.mat'));
bp_marmoset_r = load(strcat(marmosetdatapath, 'group24_blueprint/marmoset24_BP_atlas.R.mat'));

bp_human_l = bp_human_l.bp_atlas_l(:,fiber_index_l);
bp_human_r = bp_human_r.bp_atlas_r(:,fiber_index_r);
bp_marmoset_l = bp_marmoset_l.bp_atlas_l(:,fiber_index_l);
bp_marmoset_r = bp_marmoset_r.bp_atlas_r(:,fiber_index_r);

KL_L = calc_KL(bp_human_l, bp_marmoset_l);
[minKL,index] = min(KL_L,[],2);
temp_human_l.cdata = zeros(size(temp_human_l.cdata));
for i=1:105
    temp_human_l.cdata(find(atlas_human_l.cdata==i*2-1)) = minKL(i);
end
save(temp_human_l, strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas.L.func.gii'));
save(strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas.L.txt'), 'minKL', '-ascii');

[minKL,index] = min(KL_L,[],1);
temp_marmoset_l.cdata = zeros(size(temp_marmoset_l.cdata));
for i=1:106
    temp_marmoset_l.cdata(find(atlas_marmoset_l.cdata==i)) = minKL(i);
end
save(temp_marmoset_l, strcat(resultpath, 'roi_wise/mar2h_minKL_on_marmoset_atlas.L.func.gii'));

KL_R = calc_KL(bp_human_r, bp_marmoset_r);
[minKL,index] = min(KL_R,[],2);
temp_human_r.cdata = zeros(size(temp_human_r.cdata));
for i=1:105
    temp_human_r.cdata(find(atlas_human_r.cdata==i*2)) = minKL(i);
end
save(temp_human_r, strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas.R.func.gii'));
save(strcat(resultpath, 'roi_wise/mar2h_minKL_on_human_atlas.R.txt'), 'minKL', '-ascii');

[minKL,index] = min(KL_R,[],1);
temp_marmoset_r.cdata = zeros(size(temp_marmoset_r.cdata));
for i=1:106
    temp_marmoset_r.cdata(find(atlas_marmoset_r.cdata==i)) = minKL(i);
end
save(temp_marmoset_r, strcat(resultpath, 'roi_wise/mar2h_minKL_on_marmoset_atlas.R.func.gii'));

%%%%%%%%%%%%%%%
% vertex-wise %
%%%%%%%%%%%%%%%

% load blueprint
bp_human_l = ciftiopen(strcat(humandatapath, 'group40/human40_BP.L.dscalar.nii'));
bp_human_r = ciftiopen(strcat(humandatapath, 'group40/human40_BP.R.dscalar.nii'));
bp_marmoset = ciftiopen(strcat(marmosetdatapath, 'group24_blueprint/marmoset24_BP.LR.dscalar.nii'));

bp_human_l = bp_human_l.cdata(indexh_l,fiber_index_l);
bp_human_r = bp_human_r.cdata(indexh_r,fiber_index_r);
bp_marmoset_l = bp_marmoset.cdata(indexm_l,fiber_index_l);
bp_marmoset_r = bp_marmoset.cdata(indexm_r+37974,fiber_index_r);

KL_L = calc_KL(bp_human_l, bp_marmoset_l);
[minKL,index] = min(KL_L,[],2);
temp_human_l.cdata = zeros(size(temp_human_l.cdata));
temp_human_l.cdata(indexh_l) = minKL;
save(temp_human_l, strcat(resultpath, 'vertex_wise/mar2h_minKL_on_human_vertex.L.func.gii'));

[minKL,index] = min(KL_L,[],1);
temp_marmoset_l.cdata = zeros(size(temp_marmoset_l.cdata));
temp_marmoset_l.cdata(indexm_l) = minKL;
save(temp_marmoset_l, strcat(resultpath, 'vertex_wise/mar2h_minKL_on_marmoset_vertex.L.func.gii'));

KL_R = calc_KL(bp_human_r, bp_marmoset_r);
[minKL,index] = min(KL_R,[],2);
temp_human_r.cdata = zeros(size(temp_human_r.cdata));
temp_human_r.cdata(indexh_r) = minKL;
save(temp_human_r, strcat(resultpath, 'vertex_wise/mar2h_minKL_on_human_vertex.R.func.gii'));

[minKL,index] = min(KL_R,[],1);
temp_marmoset_r.cdata = zeros(size(temp_marmoset_r.cdata));
temp_marmoset_r.cdata(indexm_r) = minKL;
save(temp_marmoset_r, strcat(resultpath, 'vertex_wise/mar2h_minKL_on_marmoset_vertex.R.func.gii'));


