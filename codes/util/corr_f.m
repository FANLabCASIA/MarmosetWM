function corr_f(f)

    addpath(genpath('/n02dat01/users/yfwang/software/MatlabToolbox/NIFTI'));

    resultpath = '/n02dat01/users/yfwang/MarmosetWM/result/robustness/';
    
    %% basic information
    fibers = textread('/n02dat01/users/yfwang/MarmosetWM/result/protocols_v1.1/fiberlist.txt', '%s');

    datapath1 = '/n02dat01/users/yfwang/MarmosetWM/result/xtract_result_v1.1/';
    list1 = textread('/n02dat01/users/yfwang/Data/marmoset_MBM/marmoset_MBM_list.txt', '%s');

    datapath2 = '/n02dat01/users/yfwang/MarmosetWM/result/xtract_result_v1.1_minds/';
    list2 = textread('/n02dat01/users/yfwang/Data/marmoset_brain_minds/list_t1_dwi_aging.txt', '%s');


    %% within cohort (MBM)
    r_1 = zeros(length(list1), length(list1));
    for i=1:length(list1)-1
        for j=i+1:length(list1)
            
            x1 = load_untouch_nii(strcat(datapath1, list1{i}, '/', fibers{f}, '/densityNorm_MBMv3.nii.gz'));
            x2 = load_untouch_nii(strcat(datapath1, list1{j}, '/', fibers{f}, '/densityNorm_MBMv3.nii.gz'));
            x1.img(x1.img<0.005) = 0;
            x2.img(x2.img<0.005) = 0;
            r_1(i,j) = corr(x1.img(:), x2.img(:));
        end
    end

    %% within cohort (Brain/MINDS)
    r_2 = zeros(length(list2), length(list2));
    for i=1:length(list2)-1
        for j=i+1:length(list2)
            
            x1 = load_untouch_nii(strcat(datapath2, list2{i}, '/', fibers{f}, '/densityNorm_MBMv3.nii.gz'));
            x2 = load_untouch_nii(strcat(datapath2, list2{j}, '/', fibers{f}, '/densityNorm_MBMv3.nii.gz'));
            x1.img(x1.img<0.005) = 0;
            x2.img(x2.img<0.005) = 0;
            r_2(i,j) = corr(x1.img(:), x2.img(:));
        end
    end

    %% across cohort
    r_3 = zeros(length(list1), length(list2));
    for i=1:length(list1)
        for j=1:length(list2)
            
            x1 = load_untouch_nii(strcat(datapath1, list1{i}, '/', fibers{f}, '/densityNorm_MBMv3.nii.gz'));
            x2 = load_untouch_nii(strcat(datapath2, list2{j}, '/', fibers{f}, '/densityNorm_MBMv3.nii.gz'));
            x1.img(x1.img<0.005) = 0;
            x2.img(x2.img<0.005) = 0;
            r_3(i,j) = corr(x1.img(:), x2.img(:));
        end
    end

    save(strcat(resultpath, 'tract-wise/correlation_within_across_cohort_tract', num2str(f), '.mat'), 'r_1', 'r_2', 'r_3');
