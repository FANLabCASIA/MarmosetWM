clear;clc

addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI'));
addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/NIFTI'));

atlas_l = gifti('/n05dat/yfwang/user/MarmosetWM/support_data/atlas/chimp/ChimpAtlas_v4.L.32k_fs_LR_for_sym_show.label.gii');
atlas_r = gifti('/n05dat/yfwang/user/MarmosetWM/support_data/atlas/chimp/ChimpAtlas_v4.R.32k_fs_LR_for_sym_show.label.gii');
temp_l = gifti('/n05dat/yfwang/user/MarmosetWM/support_data/atlas/human/100307.L.atlasroi.32k_fs_LR.shape.gii');
temp_r = gifti('/n05dat/yfwang/user/MarmosetWM/support_data/atlas/human/100307.R.atlasroi.32k_fs_LR.shape.gii');

subs = textread('/n05dat/yfwang/preprocess_fsl/chimp/chimplist46.txt', '%s');
for s=1:length(subs)
    sub = subs{s};

    atlas = load_untouch_nii(strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/chimp/', sub, '/', sub, '_BNA_in_b0.nii.gz'));

    af_l = load_untouch_nii(strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/chimp/', sub, '/xtract/af_l/density.nii.gz'));
    af_r = load_untouch_nii(strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/chimp/', sub, '/xtract/af_r/density.nii.gz'));

    seed_l = load_untouch_nii(strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/chimp/', sub, '/xtract/af_l/ROI_parietal.nii.gz'));
    seed_r = load_untouch_nii(strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/chimp/', sub, '/xtract/af_r/ROI_parietal.nii.gz'));

    thr = 0;
    af_l.img(af_l.img<=thr) = 0;
    af_r.img(af_r.img<=thr) = 0;

    % count
    for i=1:100
        tmp_l = af_l.img(find(atlas.img==i+100)); tmp_l = tmp_l(tmp_l~=0);
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
    for i=1:100
        temp_l.cdata(find(atlas_l.cdata==i)) = count_norm_l(s,i);
        temp_r.cdata(find(atlas_r.cdata==i)) = count_norm_r(s,i);
    end
    save(temp_l, strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/chimp/', sub, '/', sub, '_af_l_thr', num2str(thr), '_norm.func.gii'));
    save(temp_r, strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/chimp/', sub, '/', sub, '_af_r_thr', num2str(thr), '_norm.func.gii'));
    
end

%% save count
count_norm_l = double(count_norm_l);
count_norm_r = double(count_norm_r);
save(strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/result/chimp_af_l_thr', num2str(thr), '_norm.txt'), 'count_norm_l', '-ascii');
save(strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/result/chimp_af_r_thr', num2str(thr), '_norm.txt'), 'count_norm_r', '-ascii');

%% save to gifti
temp_l.cdata = zeros(size(temp_l.cdata));
temp_r.cdata = zeros(size(temp_r.cdata));
for i=1:length(subs)
    af_l = gifti(strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/chimp/', subs{i}, '/', subs{i}, '_af_l_thr', num2str(thr), '_norm.func.gii'));
    af_r = gifti(strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/chimp/', subs{i}, '/', subs{i}, '_af_r_thr', num2str(thr), '_norm.func.gii'));
    
    temp_l.cdata = temp_l.cdata + af_l.cdata;
    temp_r.cdata = temp_r.cdata + af_r.cdata;
end
temp_l.cdata = temp_l.cdata ./ length(subs);
temp_r.cdata = temp_r.cdata ./ length(subs);
save(temp_l, strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/result/chimp_af_l_thr', num2str(thr), '_norm.func.gii'));
save(temp_r, strcat('/n05dat/yfwang/user/MarmosetWM/result/af_projection/result/chimp_af_r_thr', num2str(thr), '_norm.func.gii'));
