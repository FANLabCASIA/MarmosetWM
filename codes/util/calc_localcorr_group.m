addpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI/');

resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/af_projection_registration/';

for lr=1:2
    if lr==1
        hemi = 'L';
        hem = 'l';
    else
        hemi = 'R';
        hem = 'r';
    end

    human_af = gifti(strcat(resultpath, 'af_projection_registered_group/human_af_.', hem, '.func.gii'));
    macaque_af = gifti(strcat(resultpath, 'af_projection_registered_group//macaque-to-human_af_', hem, '.func.gii'));
    marmoset_af = gifti(strcat(resultpath, 'af_projection_registered_group/marmoset-to-human_af_', hem, '.32k.func.gii'));

    %% calculate the local correlation
    sphere = gifti(strcat('/n02dat01/users/yfwang/MarmosetWM/result/af_xspecies/registration/data/surface/human/', hemi, '.sphere.32k_fs_LR.surf.gii'));

    temp.cdata = zeros(size(temp.cdata));
    temp.cdata = surflocalcorr(human_af.cdata, macaque_af.cdata, sphere, 40);
    temp.cdata = temp.cdata .* human_af.cdata .* macaque_af.cdata;
    save(temp, strcat(resultpath, 'af_projection_registered_group_localcorr/localcorr_human_macaque_af_', hemi, '_40_weighted.func.gii'));

    temp.cdata = zeros(size(temp.cdata));
    temp.cdata = surflocalcorr(human_af.cdata, marmoset_af.cdata, sphere, 40);
    temp.cdata = temp.cdata .* human_af.cdata .* marmoset_af.cdata;
    save(temp, strcat(resultpath, 'af_projection_registered_group_localcorr/localcorr_human_marmoset_af_', hemi, '_40_weighted.func.gii'));

end
