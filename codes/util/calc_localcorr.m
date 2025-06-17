datapath = '/n05dat/yfwang/user/MarmosetWM/result/af_xspecies/';

for lr=1:2
    if lr==1
        hemi = 'l';
        HEM = 'L';
    else
        hemi = 'r';
        HEM = 'R';
    end    
    
    human = gifti(strcat(datapath, 'af_projection_registered/human_af_', hemi, '.func.gii'));
    macaque = gifti(strcat(datapath, 'af_projection_registered/macaque-to-human.af_', hemi, '.func.gii'));
    marmoset = gifti(strcat(datapath, 'af_projection_registered/marmoset-to-human.af_', hemi, '_edited.32k.func.gii'));
    
    atlas = gifti(strcat('F:\marmoset_xtract_Project\support_data\atlas\fsaverage.', HEM, '.BN_Atlas.32k_fs_LR.label.gii'));
    sphere = gifti(strcat('F:\marmoset_xtract_Project\result\af_xspecies\registration\data\surface\human\', HEM, '.sphere.32k_fs_LR.surf.gii'));
    temp = gifti(strcat(datapath, 'af_projection_registered/human_af_', hemi, '.func.gii'));

    temp.cdata = zeros(size(temp.cdata));
    temp.cdata = surflocalcorr(human.cdata, macaque.cdata, sphere, 40);
    temp.cdata = temp.cdata .* human.cdata .* macaque.cdata;
    save(temp, strcat(datapath, 'af_projection_registered_localcorr/localcorr_human_macaque_', HEM, '_40_weighted.func.gii'));

    temp.cdata = zeros(size(temp.cdata));
    temp.cdata = surflocalcorr(human.cdata, marmoset.cdata, sphere, 40);
    temp.cdata = temp.cdata .* human.cdata .* marmoset.cdata;
    save(temp, strcat(datapath, 'af_projection_registered_localcorr/localcorr_human_marmoset_', HEM, '_40_weighted.func.gii'));
    
    % A45c    
    macaque = gifti(strcat(datapath, 'af_projection_registered_localcorr/localcorr_human_macaque_', HEM, '_40_weighted.func.gii'));
    marmoset = gifti(strcat(datapath, 'af_projection_registered_localcorr/localcorr_human_marmoset_', HEM, '_40_weighted.func.gii'));

    corr_macaque = macaque.cdata(find(atlas.cdata==32+lr));
    corr_marmoset = marmoset.cdata(find(atlas.cdata==32+lr));
    
    corr_macaque = double(corr_macaque);
    corr_marmoset = double(corr_marmoset);
    
    disp(strcat('Local corr human-macaque (', hemi, '):', num2str(median(corr_macaque(corr_macaque~=0)))));
    disp(strcat('Local corr human-marmoset (', hemi, '):', num2str(median(corr_marmoset(corr_marmoset~=0)))));
    
    [h,p_macaque_marmoset] = kstest2(corr_macaque, corr_marmoset);
    disp(p_macaque_marmoset);
        
    save(strcat(datapath, 'af_projection_registered_localcorr/local_human_macaque_A45c_', HEM, '.txt'), 'corr_macaque', '-ascii');
    save(strcat(datapath, 'af_projection_registered_localcorr/local_human_marmoset_A45c_', HEM, '.txt'), 'corr_marmoset', '-ascii');
end

