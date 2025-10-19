addpath('/n05dat/yfwang/user/software/MatlabToolbox/NIFTI/');

dti_path = '/gpfs/userdata/yfwang/Data/marmoset_MBM_preprocessed/';
tract_path = '/gpfs/userdata/yfwang/MarmosetWM/result/xtract_result_MBM/';

resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/hires_af_slf/';
supportdatapath = '/gpfs/userdata/yfwang/MarmosetWM/support_data/';

subs = textread(strcat(supportdatapath, 'marmoset_MBM_list.txt'), '%s');
tracts = {'af_l', 'af_r', 'slf1_l', 'slf1_r', 'slf2_l', 'slf2_r', 'slf3_l', 'slf3_r'};

FA_all = zeros(length(subs), length(tracts));
MD_all = zeros(length(subs), length(tracts));

for s=1:length(subs)

    FA = load_untouch_nii(strcat(dti_path, subs{s}, '/DTI/dti_FA.nii.gz'));
    MD = load_untouch_nii(strcat(dti_path, subs{s}, '/DTI/dti_MD.nii.gz'));

    for t=1:length(tracts)

        tract = load_untouch_nii(strcat(tract_path, subs{s}, '/xtract/tracts/', tracts{t}, '/densityNorm.nii.gz'));
        FA_all(s,t) = nanmean(nanmean(nanmean(FA.img(find(tract.img>0.005)))));
        MD_all(s,t) = nanmean(nanmean(nanmean(MD.img(find(tract.img>0.005)))));

    end
end

save(strcat(resultpath, 'FA_MD_allMBM/FA_af_slf_allMBM.txt'), 'FA_all', '-ascii');
save(strcat(resultpath, 'FA_MD_allMBM/MD_af_slf_allMBM.txt'), 'MD_all', '-ascii');