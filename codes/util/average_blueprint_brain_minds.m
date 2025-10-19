addpath('/n05dat/yfwang/user/software/MatlabToolbox/CIFTI/');
addpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI/');

datapath = '/gpfs/userdata/yfwang/MarmosetWM/result/xtract_result_brain_minds/';
supportdatapath = '/gpfs/userdata/yfwang/MarmosetWM/support_data/';
mkdir(strcat(datapath, 'group110_blueprint/'));

subs = textread('/gpfs/userdata/yfwang/MarmosetWM/support_data/marmoset_minds_list.txt', '%s');
subs_len = length(subs);

% calculate the group average blueprint of marmosets
bp_group110 = ciftiopen(strcat(datapath, 'sub-001/sub-001_BP.LR.dscalar.nii'));
data = zeros(size(bp_group110.cdata));
for i=1:subs_len
    bp = ciftiopen(strcat(datapath, subs{i}, '/', subs{i}, '_BP.LR.dscalar.nii'));
    data = data + bp.cdata;
end
data = data / subs_len;
bp_group110.cdata = data;
ciftisave(bp_group110, strcat(datapath, 'group110_blueprint/marmoset110_BP.LR.dscalar.nii'));

% calculate the atlas-wise blueprint of marmosets
bp = ciftiopen(strcat(datapath, 'group110_blueprint/marmoset110_BP.LR.dscalar.nii'));
bp_l = bp.cdata(1:37974,:);
bp_r = bp.cdata(37975:76068,:);

atlas_l = gifti(strcat(supportdatapath, 'atlas/marmoset/surfFS.lh.MBM_cortex_vH.label.gii'));
atlas_r = gifti(strcat(supportdatapath, 'atlas/marmoset/surfFS.rh.MBM_cortex_vH.label.gii'));
roi_num = 106;

bp_atlas_l = zeros(roi_num, size(bp_l,2));
bp_atlas_r = zeros(roi_num, size(bp_r,2));
for i=1:roi_num
    index_l = find(atlas_l.cdata==i);
    bp_atlas_l(i,:) = mean(bp_l(index_l,:));
    index_r = find(atlas_r.cdata==i);
    bp_atlas_r(i,:) = mean(bp_r(index_r,:));
end
save(strcat(datapath, 'group110_blueprint/marmoset110_BP_atlas.L.mat'), 'bp_atlas_l');
save(strcat(datapath, 'group110_blueprint/marmoset110_BP_atlas.R.mat'), 'bp_atlas_r');
save(strcat(datapath, 'group110_blueprint/marmoset110_BP_atlas.L.txt'), 'bp_atlas_l', '-ascii');
save(strcat(datapath, 'group110_blueprint/marmoset110_BP_atlas.R.txt'), 'bp_atlas_r', '-ascii');
