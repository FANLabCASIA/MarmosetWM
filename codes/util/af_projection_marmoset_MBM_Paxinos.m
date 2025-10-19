clear;clc

addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI'));
addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/NIFTI'));

datapath = '/gpfs/userdata/yfwang/MarmosetWM/result/af_projection/';
resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/af_projection_comparison/';
supportdatapath = '/gpfs/userdata/yfwang/MarmosetWM/support_data/';

atlas_l = gifti('/gpfs/userdata/yfwang/MarmosetWM/support_data/MBM_v3.0.1/surfFS.lh.MBM_cortex_vPaxinos.label.gii');
atlas_r = gifti('/gpfs/userdata/yfwang/MarmosetWM/support_data/MBM_v3.0.1/surfFS.rh.MBM_cortex_vPaxinos.label.gii');
temp_l = gifti(strcat(supportdatapath, 'atlas/marmoset/surfFS.lh.atlasroi.shape.gii'));
temp_r = gifti(strcat(supportdatapath, 'atlas/marmoset/surfFS.rh.atlasroi.shape.gii'));

roi_index = unique(atlas_l.cdata);
roi_index = roi_index(2:end);
roi_num = length(roi_index);

subs = textread('/n05dat/yfwang/backup_marmoset/marmoset_MBM/marmoset_MBM_list.txt', '%s');
for s=1:length(subs)
    sub = subs{s};

    atlas = load_untouch_nii(strcat(datapath, 'marmoset_MBM/', sub, '/', sub, '_Paxinos_in_b0.nii.gz'));

    af_l = load_untouch_nii(strcat(datapath, 'marmoset_MBM/', sub, '/xtract/af_l/density.nii.gz'));
    af_r = load_untouch_nii(strcat(datapath, 'marmoset_MBM/', sub, '/xtract/af_r/density.nii.gz'));

    seed_l = load_untouch_nii(strcat(datapath, 'marmoset_MBM/', sub, '/masks/af_l/seed.nii.gz'));
    seed_r = load_untouch_nii(strcat(datapath, 'marmoset_MBM/', sub, '/masks/af_r/seed.nii.gz'));

    thr = 0;
    af_l.img(af_l.img<=thr) = 0;
    af_r.img(af_r.img<=thr) = 0;

    % count
    for i=1:roi_num
        tmp_l = af_l.img(find(atlas.img==i)); tmp_l = tmp_l(tmp_l~=0);
        tmp_r = af_r.img(find(atlas.img==i)); tmp_r = tmp_r(tmp_r~=0);

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
    for i=1:106
        temp_l.cdata(find(atlas_l.cdata==i)) = count_norm_l(s,i);
        temp_r.cdata(find(atlas_r.cdata==i)) = count_norm_r(s,i);
    end
    save(temp_l, strcat(datapath, 'marmoset_MBM/', sub, '/', sub, '_af_l_thr', num2str(thr), '_norm_Paxinos.func.gii'));
    save(temp_r, strcat(datapath, 'marmoset_MBM/', sub, '/', sub, '_af_r_thr', num2str(thr), '_norm_Paxinos.func.gii'));
    
end

%% save count
count_norm_l = double(count_norm_l);
count_norm_r = double(count_norm_r);
save(strcat(resultpath, 'atlas/marmoset_MBM_af_l_thr', num2str(thr), '_norm_Paxinos.txt'), 'count_norm_l', '-ascii');
save(strcat(resultpath, 'atlas/marmoset_MBM_af_r_thr', num2str(thr), '_norm_Paxinos.txt'), 'count_norm_r', '-ascii');

%% save to gifti
temp_l.cdata = zeros(size(temp_l.cdata));
temp_r.cdata = zeros(size(temp_r.cdata));
for i=1:length(subs)
    af_l = gifti(strcat(datapath, 'marmoset_MBM/', subs{i}, '/', subs{i}, '_af_l_thr', num2str(thr), '_norm_Paxinos.func.gii'));
    af_r = gifti(strcat(datapath, 'marmoset_MBM/', subs{i}, '/', subs{i}, '_af_r_thr', num2str(thr), '_norm_Paxinos.func.gii'));
    
    temp_l.cdata = temp_l.cdata + af_l.cdata;
    temp_r.cdata = temp_r.cdata + af_r.cdata;
end
temp_l.cdata = temp_l.cdata ./ length(subs);
temp_r.cdata = temp_r.cdata ./ length(subs);
save(temp_l, strcat(resultpath, 'atlas/marmoset_MBM_af_l_thr', num2str(thr), '_norm_Paxinos.func.gii'));
save(temp_r, strcat(resultpath, 'atlas/marmoset_MBM_af_r_thr', num2str(thr), '_norm_Paxinos.func.gii'));
