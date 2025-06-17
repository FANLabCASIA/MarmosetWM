addpath(genpath('/n02dat01/users/yfwang/software/MatlabToolbox/NIFTI'));

    supportdatapath = '/n02dat01/users/yfwang/MarmosetWM/support_data/';
    resultpath = '/n02dat01/users/yfwang/MarmosetWM/result/';

    fibers = textread(strcat(resultpath, 'fiberlist.txt'), '%s');
    mask = load_nii(strcat(supportdatapath, 'template_T2w_brain_mask.nii.gz'));

    for i=1:length(fibers)
        x1 = load_nii(strcat(resultpath, 'xtract_result_v1.1/group24_tract/thr0.005/bin_thr0.3//', fibers{i}, '_group24_0.005_bin_mean_thr0.3.nii.gz'));
        x2 = load_nii(strcat(resultpath, 'xtract_result_v1.1_minds/group110_tract/thr0.005/bin_thr0.3/', fibers{i}, '_group110_0.005_bin_mean_thr0.3.nii.gz'));
        x1img = x1.img(:);
        x2img = x2.img(:);
        x1img = x1img(find(mask.img>0));
        x2img = x2img(find(mask.img>0));
        r(i) = corr(x1img, x2img);    
    end
    disp(r)
