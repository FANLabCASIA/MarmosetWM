clear;clc

addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI'));
addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/NIFTI'));

datapath = '/gpfs/userdata/yfwang/MarmosetWM/result/af_projection/';
resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/af_projection/comparison/';
supportdatapath = '/gpfs/userdata/yfwang/MarmosetWM/support_data/';

atlas_l = gifti(strcat(supportdatapath, 'atlas/macaque/MBNA_124_32k_L.label.gii'));
atlas_r = gifti(strcat(supportdatapath, 'atlas/macaque/MBNA_124_32k_R.label.gii'));
temp_l = gifti(strcat(supportdatapath, 'atlas/human/100307.L.atlasroi.32k_fs_LR.shape.gii'));
temp_r = gifti(strcat(supportdatapath, 'atlas/human/100307.R.atlasroi.32k_fs_LR.shape.gii'));

subs = textread('/n05dat/yfwang/preprocess_fsl/macaque_ucd/macaque_ucdavis_list.txt', '%s');
for s=1:length(subs)
    sub = subs{s};

    atlas = load_untouch_nii(strcat(datapath, 'macaque_ucd/', sub, '/', sub, '_BNA_in_b0.nii.gz'));

    af_l = load_untouch_nii(strcat(datapath, 'macaque_ucd/', sub, '/xtract/af_l/density.nii.gz'));
    af_r = load_untouch_nii(strcat(datapath, 'macaque_ucd/', sub, '/xtract/af_r/density.nii.gz'));

    seed_l = load_untouch_nii(strcat(datapath, 'macaque_ucd/', sub, '/masks/af_l/seed.nii.gz'));
    seed_r = load_untouch_nii(strcat(datapath, 'macaque_ucd/', sub, '/masks/af_r/seed.nii.gz'));

    thr = 0;
    af_l.img(af_l.img<=thr) = 0;
    af_r.img(af_r.img<=thr) = 0;

    % count
    for i=1:124
        tmp_l = af_l.img(find(atlas.img==i)); tmp_l = tmp_l(tmp_l~=0);
        tmp_r = af_r.img(find(atlas.img==i+152)); tmp_r = tmp_r(tmp_r~=0);

        if length(tmp_l)==0
            count_norm_l(s,i) = 0;
        else
            count_norm_l(s,i) = mean(tmp_l) / size(find(seed_l.img>0),1);
        end

        if length(tmp_r)==0
            count_norm_r(s,i) = 0;
        else
            count_norm_r(s,i) = mean(tmp_r) / size(find(seed_r.img>0),1);
        end
    end

    % save to gifti
    temp_l.cdata = zeros(size(temp_l.cdata));
    temp_r.cdata = zeros(size(temp_r.cdata));
    for i=1:124
        temp_l.cdata(find(atlas_l.cdata==i)) = count_norm_l(s,i);
        temp_r.cdata(find(atlas_r.cdata==i)) = count_norm_r(s,i);
    end
    save(temp_l, strcat(datapath, 'macaque_ucd/', sub, '/', sub, '_af_l_thr', num2str(thr), '_norm.func.gii'));
    save(temp_r, strcat(datapath, 'macaque_ucd/', sub, '/', sub, '_af_r_thr', num2str(thr), '_norm.func.gii'));
    
end

%% save count
count_norm_l = double(count_norm_l);
count_norm_r = double(count_norm_r);
save(strcat(resultpath, 'dataset/macaque_ucd_af_l_thr', num2str(thr), '_norm.txt'), 'count_norm_l', '-ascii');
save(strcat(resultpath, 'dataset/macaque_ucd_af_r_thr', num2str(thr), '_norm.txt'), 'count_norm_r', '-ascii');

%% save to gifti
temp_l.cdata = zeros(size(temp_l.cdata));
temp_r.cdata = zeros(size(temp_r.cdata));
for i=1:length(subs)
    af_l = gifti(strcat(datapath, 'macaque_ucd/', subs{i}, '/', subs{i}, '_af_l_thr', num2str(thr), '_norm.func.gii'));
    af_r = gifti(strcat(datapath, 'macaque_ucd/', subs{i}, '/', subs{i}, '_af_r_thr', num2str(thr), '_norm.func.gii'));
    
    temp_l.cdata = temp_l.cdata + af_l.cdata;
    temp_r.cdata = temp_r.cdata + af_r.cdata;
end
temp_l.cdata = temp_l.cdata ./ length(subs);
temp_r.cdata = temp_r.cdata ./ length(subs);
save(temp_l, strcat(resultpath, 'dataset/macaque_ucd_af_l_thr', num2str(thr), '_norm.func.gii'));
save(temp_r, strcat(resultpath, 'dataset/macaque_ucd_af_r_thr', num2str(thr), '_norm.func.gii'));
