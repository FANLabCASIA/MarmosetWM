addpath('/n05dat/yfwang/user/software/MatlabToolbox/CIFTI/');
addpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI/');

datapath = '/gpfs/userdata/yfwang/MarmosetWM/result/xtract_result_MBM/';
resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/connectivity_divergence/bp_atlas_indi/';
supportdatapath = '/gpfs/userdata/yfwang/MarmosetWM/support_data/';

atlas_l = gifti(strcat(supportdatapath, 'atlas/marmoset/surfFS.lh.MBM_cortex_vH.label.gii'));
atlas_r = gifti(strcat(supportdatapath, 'atlas/marmoset/surfFS.rh.MBM_cortex_vH.label.gii'));
roi_num = 106;

subs = textread('/gpfs/userdata/yfwang/MarmosetWM/support_data/marmoset_MBM_list.txt', '%s');
subs_len = length(subs);

for i=1:subs_len

    bp = ciftiopen(strcat(datapath, subs{i}, '/', subs{i}, '_BP.LR.dscalar.nii'));
    bp_l = bp.cdata(1:37974,:);
    bp_r = bp.cdata(37975:76068,:);

    bp_atlas_l = zeros(roi_num, size(bp_l,2));
    bp_atlas_r = zeros(roi_num, size(bp_r,2));
    for j=1:roi_num
        index_l = find(atlas_l.cdata==j);
        bp_atlas_l(j,:) = mean(bp_l(index_l,:));
        index_r = find(atlas_r.cdata==j);
        bp_atlas_r(j,:) = mean(bp_r(index_r,:));
    end
    
    save(strcat(resultpath, 'marmoset_MBM/', subs{i}, '_BP_atlas.L.txt'), 'bp_atlas_l', '-ascii');
    save(strcat(resultpath, 'marmoset_MBM/', subs{i}, '_BP_atlas.R.txt'), 'bp_atlas_r', '-ascii');
end
