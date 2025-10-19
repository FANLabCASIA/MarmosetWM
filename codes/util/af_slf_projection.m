addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/NIFTI/'));
addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI/'));

resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/hires_af_slf/';
supportdatapath = '/gpfs/userdata/yfwang/MarmosetWM/support_data/';

atlas_MBM = load_untouch_nii(strcat(resultpath, 'MBMvH_80um.nii.gz'));

atlas_l = gifti(strcat(supportdatapath, 'MBM_v3.0.1/surfFS.lh.MBM_cortex_vH.label.gii'));
atlas_r = gifti(strcat(supportdatapath, 'MBM_v3.0.1/surfFS.rh.MBM_cortex_vH.label.gii'));
temp_l = gifti(strcat(supportdatapath, 'MBM_v3.0.1/surfFS.lh.atlasroi.shape.gii'));
temp_r = gifti(strcat(supportdatapath, 'MBM_v3.0.1/surfFS.rh.atlasroi.shape.gii'));

tracts = {'af', 'slf1', 'slf2', 'slf3'};

for t=1:length(tracts)
    
    tract = tracts{t};

    tract_l = load_untouch_nii(strcat(resultpath, 'xtract/', tract, '_l/densityNorm.nii.gz'));
    tract_r = load_untouch_nii(strcat(resultpath, 'xtract/', tract, '_r/densityNorm.nii.gz'));
    
    seed_l = load_untouch_nii(strcat(resultpath, 'masks/', tract, '_l/seed.nii.gz'));
    seed_r = load_untouch_nii(strcat(resultpath, 'masks/', tract, '_r/seed.nii.gz'));
    
    thr = 0;
    tract_l.img(tract_l.img<=thr) = 0;
    tract_r.img(tract_r.img<=thr) = 0;

    % count
    for i=1:106
        tmp_l = tract_l.img(find(atlas_MBM.img==i)); tmp_l = tmp_l(tmp_l~=0);
        tmp_r = tract_r.img(find(atlas_MBM.img==i)); tmp_r = tmp_r(tmp_r~=0);

        if length(tmp_l)==0
            count_norm_l(i) = 0;
        else
            count_norm_l(i) = mean(tmp_l) / size(find(seed_l.img>0),1);
        end
        
        if length(tmp_r)==0
            count_norm_r(i) = 0;
        else
            count_norm_r(i) = mean(tmp_r) / size(find(seed_r.img>0),1);
        end
    end

    % save to gifti
    temp_l.cdata = zeros(size(temp_l.cdata));
    temp_r.cdata = zeros(size(temp_r.cdata));
    for i=1:106
        temp_l.cdata(find(atlas_l.cdata==i)) = count_norm_l(i);
        temp_r.cdata(find(atlas_r.cdata==i)) = count_norm_r(i);
    end
    save(temp_l, strcat(resultpath, 'projection/', tract, '_l_thr', num2str(thr), '_norm.func.gii'));
    save(temp_r, strcat(resultpath, 'projection/', tract, '_r_thr', num2str(thr), '_norm.func.gii'));
    
    count_norm_l = double(count_norm_l);
    count_norm_r = double(count_norm_r);
    
    save(strcat(resultpath, 'projection/', tract, '_l_thr', num2str(thr), '_norm.txt'), 'count_norm_l', '-ascii');
    save(strcat(resultpath, 'projection/', tract, '_r_thr', num2str(thr), '_norm.txt'), 'count_norm_r', '-ascii');
end