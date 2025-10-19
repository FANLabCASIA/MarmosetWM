addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/NIFTI'));

resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/af_projection_comparison/volume/';

% human
subs = textread('/gpfs/userdata/yfwang/preprocess_mrtrix/human/HCP40_list.txt', '%s');

volume_human = zeros(length(subs), 3);
for i=1:length(subs)
    
    disp(subs{i})
    subdir = strcat('/gpfs/userdata/yfwang/MarmosetWM/tmp/', subs{i}, '/');
    cgm = load_untouch_nii(strcat(subdir, '5tt.freesurfer.cgm.nii.gz'));
    sgm = load_untouch_nii(strcat(subdir, '5tt.freesurfer.sgm.nii.gz'));
    wm = load_untouch_nii(strcat(subdir, '5tt.freesurfer.wm.nii.gz'));
    csf = load_untouch_nii(strcat(subdir, '5tt.freesurfer.csf.nii.gz'));
    path = load_untouch_nii(strcat(subdir, '5tt.freesurfer.path.nii.gz'));

    volume_cgm = size(find(cgm.img>0),1) * 1 * 1 * 1;
    volume_sgm = size(find(sgm.img>0),1) * 1 * 1 * 1;
    volume_wm = size(find(wm.img>0),1) * 1 * 1 * 1;
    volume_csf = size(find(csf.img>0),1) * 1 * 1 * 1;
    volume_path = size(find(path.img>0),1) * 1 * 1 * 1;

    volume_human(i,1) = volume_cgm + volume_sgm + volume_wm + volume_csf + volume_path;
    volume_human(i,2) = volume_cgm + volume_sgm;
    volume_human(i,3) = volume_wm;
end
save(strcat(resultpath, 'volume_human.txt'), 'volume_human', '-ascii');

%% chimp
subs = textread('/gpfs/userdata/yfwang/preprocess_mrtrix/chimp/chimplist46.txt', '%s');

volume_chimp = zeros(length(subs), 3);
for i=1:length(subs)
    
    disp(subs{i})
    subdir = strcat('/gpfs/userdata/yfwang/preprocess_mrtrix/chimp/', subs{i}, '/');
    cgm = load_untouch_nii(strcat(subdir, 'mask_cgm_in_b0.nii.gz'));
    sgm = load_untouch_nii(strcat(subdir, 'mask_sgm_in_b0.nii.gz'));
    wm = load_untouch_nii(strcat(subdir, 'mask_wm_in_b0.nii.gz'));
    csf = load_untouch_nii(strcat(subdir, 'mask_csf_in_b0.nii.gz'));
    path = load_untouch_nii(strcat(subdir, 'mask_path_in_b0.nii.gz'));

    volume_cgm = size(find(cgm.img>0),1) * 1.9 * 1.9 * 1.9;
    volume_sgm = size(find(sgm.img>0),1) * 1.9 * 1.9 * 1.9;
    volume_wm = size(find(wm.img>0),1) * 1.9 * 1.9 * 1.9;
    volume_csf = size(find(csf.img>0),1) * 1.9 * 1.9 * 1.9;
    volume_path = size(find(path.img>0),1) * 1.9 * 1.9 * 1.9;

    volume_chimp(i,1) = volume_cgm + volume_sgm + volume_wm + volume_csf + volume_path;
    volume_chimp(i,2) = volume_cgm + volume_sgm;
    volume_chimp(i,3) = volume_wm;
end
save(strcat(resultpath, 'volume_chimp.txt'), 'volume_chimp', '-ascii');

%% macaque
subs = textread('/gpfs/userdata/yfwang/preprocess_mrtrix/macaque_tvb/macaque_tvb_list.txt', '%s');

volume_macaque = zeros(length(subs), 3);
for i=1:length(subs)
    
    disp(subs{i})
    subdir = strcat('/gpfs/userdata/yfwang/preprocess_mrtrix/macaque_tvb/', subs{i}, '/');
    cgm = load_untouch_nii(strcat(subdir, 'mask_cgm_in_b0.nii.gz'));
    sgm = load_untouch_nii(strcat(subdir, 'mask_sgm_in_b0.nii.gz'));
    wm = load_untouch_nii(strcat(subdir, 'mask_wm_in_b0.nii.gz'));
    csf = load_untouch_nii(strcat(subdir, 'mask_csf_in_b0.nii.gz'));
    path = load_untouch_nii(strcat(subdir, 'mask_path_in_b0.nii.gz'));

    volume_cgm = size(find(cgm.img>0),1) * 1 * 1 * 1.1;
    volume_sgm = size(find(sgm.img>0),1) * 1 * 1 * 1.1;
    volume_wm = size(find(wm.img>0),1) * 1 * 1 * 1.1;
    volume_csf = size(find(csf.img>0),1) * 1 * 1 * 1.1;
    volume_path = size(find(path.img>0),1) * 1 * 1 * 1.1;

    volume_macaque(i,1) = volume_cgm + volume_sgm + volume_wm + volume_csf + volume_path;
    volume_macaque(i,2) = volume_cgm + volume_sgm;
    volume_macaque(i,3) = volume_wm;
end
save(strcat(resultpath, 'volume_macaque.txt'), 'volume_macaque', '-ascii');


%% marmoset
subs = textread('/gpfs/userdata/yfwang/Data/marmoset_MBM_preprocessed/marmoset_MBM_list.txt', '%s');

volume_marmoset = zeros(length(subs), 3);
for i=1:length(subs)
    
    disp(subs{i})
    subdir = strcat('/gpfs/userdata/yfwang/Data/marmoset_MBM_preprocessed/', subs{i}, '/');
    cgm = load_untouch_nii(strcat(subdir, 'mask_cgm_in_b0.nii.gz'));
    sgm = load_untouch_nii(strcat(subdir, 'mask_sgm_in_b0.nii.gz'));
    wm = load_untouch_nii(strcat(subdir, 'mask_wm_in_b0.nii.gz'));
    csf = load_untouch_nii(strcat(subdir, 'mask_csf_in_b0.nii.gz'));
    path = load_untouch_nii(strcat(subdir, 'mask_path_in_b0.nii.gz'));

    volume_cgm = size(find(cgm.img>0),1) * 0.5 * 0.5 * 0.5;
    volume_sgm = size(find(sgm.img>0),1) * 0.5 * 0.5 * 0.5;
    volume_wm = size(find(wm.img>0),1) * 0.5 * 0.5 * 0.5;
    volume_csf = size(find(csf.img>0),1) * 0.5 * 0.5 * 0.5;
    volume_path = size(find(path.img>0),1) * 0.5 * 0.5 * 0.5;

    volume_marmoset(i,1) = volume_cgm + volume_sgm + volume_wm + volume_csf + volume_path;
    volume_marmoset(i,2) = volume_cgm + volume_sgm;
    volume_marmoset(i,3) = volume_wm;
end
save(strcat(resultpath, 'volume_marmoset.txt'), 'volume_marmoset', '-ascii');