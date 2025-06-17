addpath('/n05dat/yfwang/user/software/MatlabToolbox/CIFTI/');
addpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI/');


marmosetdatapath='/n05dat/yfwang/user/MarmosetWM/result/xtract_result_v1.1_minds/';
mkdir(strcat(marmosetdatapath, 'group110_blueprint/'));

subs = textread('/n05dat/yfwang/backup_marmoset/marmoset_brain_minds/list_t1_dwi_aging.txt', '%s');
subs_len = length(subs);

% calculate the group average blueprint of marmosets
bp_group110 = ciftiopen(strcat(marmosetdatapath, 'sub-001/sub-001_BP.LR.dscalar.nii'));
data = zeros(size(bp_group110.cdata));
for i=1:subs_len
    bp = ciftiopen(strcat(marmosetdatapath, subs{i}, '/', subs{i}, '_BP.LR.dscalar.nii'));
    data = data + bp.cdata;
end
data = data / subs_len;
bp_group110.cdata = data;
ciftisave(bp_group110, strcat(marmosetdatapath, 'group110_blueprint/marmoset110_BP.LR.dscalar.nii'));

% calculate the atlas-wise blueprint of marmosets
bp = ciftiopen(strcat(marmosetdatapath, 'group110_blueprint/marmoset110_BP.LR.dscalar.nii'));
bp_l = bp.cdata(1:37974,:);
bp_r = bp.cdata(37975:76068,:);

atlas_l = gifti('/n05dat/yfwang/user/MarmosetWM/support_data/MBM_v3.0.1/surfFS.lh.MBM_cortex_vH.label.gii');
atlas_r = gifti('/n05dat/yfwang/user/MarmosetWM/support_data/MBM_v3.0.1/surfFS.rh.MBM_cortex_vH.label.gii');
roi_num = 106;

bp_atlas_l = zeros(roi_num, size(bp_l,2));
bp_atlas_r = zeros(roi_num, size(bp_r,2));
for i=1:roi_num
    index_l = find(atlas_l.cdata==i);
    bp_atlas_l(i,:) = mean(bp_l(index_l,:));
    index_r = find(atlas_r.cdata==i);
    bp_atlas_r(i,:) = mean(bp_r(index_r,:));
end
save(strcat(marmosetdatapath, 'group110_blueprint/marmoset110_BP_atlas.L.mat'), 'bp_atlas_l');
save(strcat(marmosetdatapath, 'group110_blueprint/marmoset110_BP_atlas.R.mat'), 'bp_atlas_r');
save(strcat(marmosetdatapath, 'group110_blueprint/marmoset110_BP_atlas.L.txt'), 'bp_atlas_l', '-ascii');
save(strcat(marmosetdatapath, 'group110_blueprint/marmoset110_BP_atlas.R.txt'), 'bp_atlas_r', '-ascii');
