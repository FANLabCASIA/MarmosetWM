addpath('/n05dat/yfwang/user/software/MatlabToolbox/CIFTI/');
addpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI/');

datapath = '/gpfs/userdata/yfwang/preprocess_fsl/chimp/';
resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/connectivity_divergence/bp_atlas_indi/';
supportdatapath = '/gpfs/userdata/yfwang/MarmosetWM/support_data/';

atlas_l = gifti(strcat(supportdatapath, 'atlas/chimp/ChimpAtlas_v4.L.32k_fs_LR_for_sym_show.label.gii'));
atlas_r = gifti(strcat(supportdatapath, 'atlas/chimp/ChimpAtlas_v4.R.32k_fs_LR_for_sym_show.label.gii'));
roi_num = 100;

subs = textread('/n05dat/yfwang/preprocess_fsl/chimp/chimplist46.txt', '%s');
subs_len = length(subs);

for i=1:subs_len

    bp = ciftiopen(strcat(datapath, subs{i}, '/', subs{i}, '_BP.LR.dscalar.nii'));
    bp_l = bp.cdata(1:32492,:);
    bp_r = bp.cdata(32493:64984,:);

    bp_atlas_l = zeros(roi_num, size(bp_l,2));
    bp_atlas_r = zeros(roi_num, size(bp_r,2));
    for j=1:roi_num
        index_l = find(atlas_l.cdata==j);
        bp_atlas_l(j,:) = mean(bp_l(index_l,:));
        index_r = find(atlas_r.cdata==j);
        bp_atlas_r(j,:) = mean(bp_r(index_r,:));
    end
    
    save(strcat(resultpath, 'chimp/', subs{i}, '_BP_atlas.L.txt'), 'bp_atlas_l', '-ascii');
    save(strcat(resultpath, 'chimp/', subs{i}, '_BP_atlas.R.txt'), 'bp_atlas_r', '-ascii');
end
