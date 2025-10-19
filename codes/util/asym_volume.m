addpath('/n05dat/yfwang/user/software/MatlabToolbox/NIFTI/');

resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/asym_volume/';

human_list = textread('/gpfs/userdata/yfwang/preprocess_fsl/human/humanlist40.txt', '%s');
chimp_list = textread('/gpfs/userdata/yfwang/preprocess_fsl/chimp/chimplist46.txt', '%s');
macaque_list = textread('/gpfs/userdata/yfwang/preprocess_fsl/macaque_tvb/macaque_tvb_list.txt', '%s');
marmoset_list = textread('/gpfs/userdata/yfwang/Data/marmoset_MBM_preprocessed/marmoset_MBM_list.txt', '%s');

thr = 0.005;

%% human
human_af_l = zeros(length(human_list),1);
human_af_r = zeros(length(human_list),1);
for i=1:length(human_list)
    
    tmp_l = load_untouch_nii(strcat('/n08dat03/atlas_group/yhlu/data_bakup/Human/xtract_prep/HCP_40/', human_list{i}, '/tracts/af_l/densityNorm.nii.gz'));
    tmp_r = load_untouch_nii(strcat('/n08dat03/atlas_group/yhlu/data_bakup/Human/xtract_prep/HCP_40/', human_list{i}, '/tracts/af_r/densityNorm.nii.gz'));
    
    human_af_l(i) = size(find(tmp_l.img>thr),1)*1.25*1.25*1.25;
    human_af_r(i) = size(find(tmp_r.img>thr),1)*1.25*1.25*1.25;
end

%% chimp
chimp_af_l = zeros(length(chimp_list),1);
chimp_af_r = zeros(length(chimp_list),1);
for i=1:length(chimp_list)
    
    tmp_l = load_untouch_nii(strcat('/gpfs/userdata/yfwang/preprocess_fsl/chimp/', chimp_list{i}, '/tracts/af_l/densityNorm.nii.gz'));
    tmp_r = load_untouch_nii(strcat('/gpfs/userdata/yfwang/preprocess_fsl/chimp/', chimp_list{i}, '/tracts/af_r/densityNorm.nii.gz'));
    
    chimp_af_l(i) = size(find(tmp_l.img>thr),1)*1.9*1.9*1.9;
    chimp_af_r(i) = size(find(tmp_r.img>thr),1)*1.9*1.9*1.9;
end

%% macaque
macaque_af_l = zeros(length(macaque_list),1);
macaque_af_r = zeros(length(macaque_list),1);
for i=1:length(macaque_list)
    
    tmp_l = load_untouch_nii(strcat('/gpfs/userdata/yfwang/preprocess_fsl/macaque_tvb/', macaque_list{i}, '/tracts/af_l/densityNorm.nii.gz'));
    tmp_r = load_untouch_nii(strcat('/gpfs/userdata/yfwang/preprocess_fsl/macaque_tvb/', macaque_list{i}, '/tracts/af_r/densityNorm.nii.gz'));
    
    macaque_af_l(i) = size(find(tmp_l.img>thr),1)*1*1*1;
    macaque_af_r(i) = size(find(tmp_r.img>thr),1)*1*1*1;
end

%% marmoset
marmoset_af_l = zeros(length(marmoset_list),1);
marmoset_af_r = zeros(length(marmoset_list),1);
for i=1:length(marmoset_list)
    
    tmp_l = load_untouch_nii(strcat('/gpfs/userdata/yfwang/MarmosetWM/result/xtract_result_MBM/', marmoset_list{i}, '/tracts/af_l/densityNorm.nii.gz'));
    tmp_r = load_untouch_nii(strcat('/gpfs/userdata/yfwang/MarmosetWM/result/xtract_result_MBM/', marmoset_list{i}, '/tracts/af_r/densityNorm.nii.gz'));
    
    marmoset_af_l(i) = size(find(tmp_l.img>thr),1)*0.5*0.5*0.5;
    marmoset_af_r(i) = size(find(tmp_r.img>thr),1)*0.5*0.5*0.5;
end

save(strcat(resultpath, 'human_af_l_volume.txt'), 'human_af_l', '-ascii');
save(strcat(resultpath, 'human_af_r_volume.txt'), 'human_af_r', '-ascii');
save(strcat(resultpath, 'chimp_af_l_volume.txt'), 'chimp_af_l', '-ascii');
save(strcat(resultpath, 'chimp_af_r_volume.txt'), 'chimp_af_r', '-ascii');
save(strcat(resultpath, 'macaque_af_l_volume.txt'), 'macaque_af_l', '-ascii');
save(strcat(resultpath, 'macaque_af_r_volume.txt'), 'macaque_af_r', '-ascii');
save(strcat(resultpath, 'marmoset_af_l_volume.txt'), 'marmoset_af_l', '-ascii');
save(strcat(resultpath, 'marmoset_af_r_volume.txt'), 'marmoset_af_r', '-ascii');

[h,p,ci,stats] = ttest(human_af_l, human_af_r);
disp(strcat('human: t=', num2str(stats.tstat), ', p=', num2str(p)));

[h,p,ci,stats] = ttest(chimp_af_l, chimp_af_r);
disp(strcat('chimp: t=', num2str(stats.tstat), ', p=', num2str(p)));

[h,p,ci,stats] = ttest(macaque_af_l, macaque_af_r);
disp(strcat('macaque: t=', num2str(stats.tstat), ', p=', num2str(p)));

[h,p,ci,stats] = ttest(marmoset_af_l, marmoset_af_r);
disp(strcat('marmoset: t=', num2str(stats.tstat), ', p=', num2str(p)));

% output:
% human: t=5.1811, p=7.0609e-06
% chimp: t=-0.69761, p=0.48901
% macaque: t=0.56566, p=0.58929
% marmoset: t=-0.63908, p=0.52908
