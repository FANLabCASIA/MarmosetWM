addpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI/');

datapath = '/gpfs/userdata/yfwang/MarmosetWM/result/af_projection/result/';
resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/asym_projection/';
supportdatapath = '/gpfs/userdata/yfwang/MarmosetWM/support_data/atlas/';

atlas_human_l = gifti(strcat(supportdatapath, 'human/fsaverage.L.BN_Atlas.32k_fs_LR.label.gii'));
atlas_human_r = gifti(strcat(supportdatapath, 'human/fsaverage.R.BN_Atlas.32k_fs_LR.label.gii'));

atlas_chimp_l = gifti(strcat(supportdatapath, 'chimp/ChimpAtlas_v4.L.32k_fs_LR_for_sym_show.label.gii'));
atlas_chimp_r = gifti(strcat(supportdatapath, 'chimp/ChimpAtlas_v4.R.32k_fs_LR_for_sym_show.label.gii'));

atlas_macaque_l = gifti(strcat(supportdatapath, 'macaque/MBNA_124_32k_L.label.gii'));
atlas_macaque_r = gifti(strcat(supportdatapath, 'macaque/MBNA_124_32k_R.label.gii'));

atlas_marmoset_l = gifti(strcat(supportdatapath, 'marmoset/surfFS.lh.MBM_cortex_vH.label.gii'));
atlas_marmoset_r = gifti(strcat(supportdatapath, 'marmoset/surfFS.rh.MBM_cortex_vH.label.gii'));

pthr = 0.001;


%% human
human_af_l = load(strcat(datapath, 'human_af_l_thr0_norm.txt'));
human_af_r = load(strcat(datapath, 'human_af_r_thr0_norm.txt'));

for i=1:105
    [h,p_human(i),ci,stats] = ttest(human_af_l(:,i), human_af_r(:,i));
    t_human(i) = stats.tstat;
end
[p_human_fwe, ~] = brant_MulCC(p_human, pthr, 'bonf');

temp_l = gifti(strcat(supportdatapath, 'human/100307.L.atlasroi.32k_fs_LR.shape.gii'));
temp_r = gifti(strcat(supportdatapath, 'human/100307.R.atlasroi.32k_fs_LR.shape.gii'));
temp_l.cdata = zeros(size(temp_l.cdata));
temp_r.cdata = zeros(size(temp_r.cdata));
for i=1:105
    if p_human(i) < p_human_fwe
        if t_human(i) > 0
            temp_l.cdata(find(atlas_human_l.cdata==i*2-1)) = t_human(i);
        else
            temp_r.cdata(find(atlas_human_r.cdata==i*2)) = t_human(i);
        end
    end
end
save(temp_l, strcat(resultpath, 'human_af_asym_fwe', num2str(pthr), '.L.func.gii'));
save(temp_r, strcat(resultpath, 'human_af_asym_fwe', num2str(pthr), '.R.func.gii'));


%% chimp
chimp_af_l = load(strcat(datapath, 'chimp_af_l_thr0_norm.txt'));
chimp_af_r = load(strcat(datapath, 'chimp_af_r_thr0_norm.txt'));

for i=1:100
    [h,p_chimp(i),ci,stats] = ttest(chimp_af_l(:,i), chimp_af_r(:,i));
    t_chimp(i) = stats.tstat;
end
[p_chimp_fwe, ~] = brant_MulCC(p_chimp, pthr, 'bonf');

temp_l = gifti(strcat(supportdatapath, 'chimp/chimp.L.atlasroi.32k_fs_LR.shape.gii'));
temp_r = gifti(strcat(supportdatapath, 'chimp/chimp.R.atlasroi.32k_fs_LR.shape.gii'));
temp_l.cdata = zeros(size(temp_l.cdata));
temp_r.cdata = zeros(size(temp_r.cdata));
for i=1:100
    if p_chimp(i) < p_chimp_fwe
        if t_chimp(i) > 0
            temp_l.cdata(find(atlas_chimp_l.cdata==i)) = t_chimp(i);
        else
            temp_r.cdata(find(atlas_chimp_r.cdata==i)) = t_chimp(i);
        end
    end
end
save(temp_l, strcat(resultpath, 'chimp_af_asym_fwe', num2str(pthr), '.L.func.gii'));
save(temp_r, strcat(resultpath, 'chimp_af_asym_fwe', num2str(pthr), '.R.func.gii'));


%% macaque
macaque_af_l = load(strcat(datapath, 'macaque_tvb_af_l_thr0_norm.txt'));
macaque_af_r = load(strcat(datapath, 'macaque_tvb_af_r_thr0_norm.txt'));

for i=1:124
    [h,p_macaque(i),ci,stats] = ttest(macaque_af_l(:,i), macaque_af_r(:,i));
    t_macaque(i) = stats.tstat;
end
[p_macaque_fwe, ~] = brant_MulCC(p_macaque, pthr, 'bonf');

temp_l = gifti(strcat(supportdatapath, 'macaque/civm.L.roi.BNA_surface.32k_fs_LR.func.gii'));
temp_r = gifti(strcat(supportdatapath, 'macaque/civm.R.roi.BNA_surface.32k_fs_LR.func.gii'));
temp_l.cdata = zeros(size(temp_l.cdata));
temp_r.cdata = zeros(size(temp_r.cdata));
for i=1:124
    if p_macaque(i) < p_macaque_fwe
        if t_macaque(i) > 0
            temp_l.cdata(find(atlas_macaque_l.cdata==i)) = t_macaque(i);
        else
            temp_r.cdata(find(atlas_macaque_r.cdata==i)) = t_macaque(i);
        end
    end
end
save(temp_l, strcat(resultpath, 'macaque_tvb_af_asym_fwe', num2str(pthr), '.L.func.gii'));
save(temp_r, strcat(resultpath, 'macaque_tvb_af_asym_fwe', num2str(pthr), '.R.func.gii'));


%% marmoset
marmoset_af_l = load(strcat(datapath, 'marmoset_MBM_af_l_thr0_norm.txt'));
marmoset_af_r = load(strcat(datapath, 'marmoset_MBM_af_r_thr0_norm.txt'));

for i=1:106
    [h,p_marmoset(i),ci,stats] = ttest(marmoset_af_l(:,i), marmoset_af_r(:,i));
    t_marmoset(i) = stats.tstat;
end
[p_marmoset_fwe, ~] = brant_MulCC(p_marmoset, pthr, 'bonf');

temp_l = gifti(strcat(supportdatapath, 'marmoset/surfFS.lh.atlasroi.shape.gii'));
temp_r = gifti(strcat(supportdatapath, 'marmoset/surfFS.rh.atlasroi.shape.gii'));
temp_l.cdata = zeros(size(temp_l.cdata));
temp_r.cdata = zeros(size(temp_r.cdata));
for i=1:106
    if p_marmoset(i) < p_marmoset_fwe
        if t_marmoset(i) > 0
            temp_l.cdata(find(atlas_marmoset_l.cdata==i)) = t_marmoset(i);
        else
            temp_r.cdata(find(atlas_marmoset_r.cdata==i)) = t_marmoset(i);
        end
    end
end
save(temp_l, strcat(resultpath, 'marmoset_MBM_af_asym_fwe', num2str(pthr), '.L.func.gii'));
save(temp_r, strcat(resultpath, 'marmoset_MBM_af_asym_fwe', num2str(pthr), '.R.func.gii'));