addpath('/n05dat/yfwang/user/software/MatlabToolbox/CIFTI/');
addpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI/');

datapath = '/gpfs/userdata/yfwang/preprocess_fsl/human/';
resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/connectivity_divergence/bp_atlas_indi/';
supportdatapath = '/gpfs/userdata/yfwang/MarmosetWM/support_data/';

atlas_l = gifti(strcat(supportdatapath, 'atlas/human/fsaverage.L.BN_Atlas.32k_fs_LR.label.gii'));
atlas_r = gifti(strcat(supportdatapath, 'atlas/human/fsaverage.R.BN_Atlas.32k_fs_LR.label.gii'));
roi_num = 105;

subs = textread('/gpfs/userdata/yfwang/preprocess_fsl/human/humanlist40.txt', '%s');
subs_len = length(subs);

for i=1:subs_len

    bp_l = ciftiopen(strcat(datapath, subs{i}, '/', subs{i}, '_BP.L.dscalar.nii'));
    bp_r = ciftiopen(strcat(datapath, subs{i}, '/', subs{i}, '_BP.R.dscalar.nii'));
    bp_l = bp_l.cdata(1:32492,:);
    bp_r = bp_r.cdata(1:32492,:);

    bp_atlas_l = zeros(roi_num, size(bp_l,2));
    bp_atlas_r = zeros(roi_num, size(bp_r,2));
    for j=1:roi_num
        index_l = find(atlas_l.cdata==j*2-1);
        bp_atlas_l(j,:) = mean(bp_l(index_l,:));
        index_r = find(atlas_r.cdata==j*2);
        bp_atlas_r(j,:) = mean(bp_r(index_r,:));
    end
    
    save(strcat(resultpath, 'human/', subs{i}, '_BP_atlas.L.txt'), 'bp_atlas_l', '-ascii');
    save(strcat(resultpath, 'human/', subs{i}, '_BP_atlas.R.txt'), 'bp_atlas_r', '-ascii');
end
