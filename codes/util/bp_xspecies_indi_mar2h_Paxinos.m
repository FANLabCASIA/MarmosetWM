%% human vs. marmoset

resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/connectivity_divergence/';
supportdatapath = '/gpfs/userdata/yfwang/MarmosetWM/support_data/';

% fibers = ['AC', 'AF', 'AR', 'ATR', 'CBD', 'CBP', 'CBT', 'CST', 'FA',   'FX',   'IFOF', 'ILF',   'MDLF', 'OR', 'PTR', 'SLF1', 'SLF2', 'SLF3', 'STR', 'UF', 'VOF', 'FMA', 'FMI', 'MCP']
fiber_index_l = [1,3,5,7,9,11,13,15,17,21,42,44,24,26,28,30,32,34,36,38,40,19,20,23];
fiber_index_r = [2,4,6,8,10,12,14,16,18,22,43,45,25,27,29,31,33,35,37,39,41,19,20,23];

% load atlas
atlas_human_l = gifti(strcat(supportdatapath, 'atlas/human/fsaverage.L.BN_Atlas.32k_fs_LR.label.gii'));
atlas_human_r = gifti(strcat(supportdatapath, 'atlas/human/fsaverage.R.BN_Atlas.32k_fs_LR.label.gii'));

% load cerebral roi
hroi_l_file = gifti(strcat(supportdatapath, 'atlas/human/100307.L.atlasroi.32k_fs_LR.shape.gii'));
hroi_r_file = gifti(strcat(supportdatapath, 'atlas/human/100307.R.atlasroi.32k_fs_LR.shape.gii'));
indexh_l = find(hroi_l_file.cdata>0);
indexh_r = find(hroi_r_file.cdata>0);

temp_human_l = gifti(strcat(supportdatapath, 'atlas/human/100307.L.atlasroi.32k_fs_LR.shape.gii'));
temp_human_r = gifti(strcat(supportdatapath, 'atlas/human/100307.R.atlasroi.32k_fs_LR.shape.gii'));

% calculate minKL between human and marmoset (subject level)
subs_human = textread('humanlist40.txt', '%s');
subs_marmoset = textread('marmoset_MBM_list.txt', '%s');

minKL_mar2h_all_L = zeros(length(subs_human), length(subs_marmoset), 105);
minKL_mar2h_all_R = zeros(length(subs_human), length(subs_marmoset), 105);

for h=1:length(subs_human)
    for m=1:length(subs_marmoset)
        disp(strcat(num2str(h), '-', num2str(m)));
        
        bp_human_l = load(strcat(resultpath, 'bp_atlas_indi/human/', subs_human{h}, '_BP_atlas.L.txt'));
        bp_human_r = load(strcat(resultpath, 'bp_atlas_indi/human/', subs_human{h}, '_BP_atlas.R.txt'));
        bp_human_l = bp_human_l(:,fiber_index_l);
        bp_human_r = bp_human_r(:,fiber_index_r);
        
        bp_marmoset_l = load(strcat(resultpath, 'bp_atlas_indi/marmoset_Paxinos/', subs_marmoset{m}, '_BP_atlas_Paxinos.L.txt'));
        bp_marmoset_r = load(strcat(resultpath, 'bp_atlas_indi/marmoset_Paxinos/', subs_marmoset{m}, '_BP_atlas_Paxinos.R.txt'));
        bp_marmoset_l = bp_marmoset_l(:,fiber_index_l);
        bp_marmoset_r = bp_marmoset_r(:,fiber_index_r);
        
        KL_L = calc_KL(bp_human_l, bp_marmoset_l);
        [minKL_mar2h_all_L(h, m, :), ~] = min(KL_L,[],2);
        
        KL_R = calc_KL(bp_human_r, bp_marmoset_r);
        [minKL_mar2h_all_R(h, m, :), ~] = min(KL_R,[],2);

    end
end

minKL_mar2h_L = squeeze(mean(mean(minKL_mar2h_all_L)));
minKL_mar2h_R = squeeze(mean(mean(minKL_mar2h_all_R)));

temp_human_l.cdata = zeros(size(temp_human_l.cdata));
temp_human_r.cdata = zeros(size(temp_human_r.cdata));
for i=1:105
    temp_human_l.cdata(find(atlas_human_l.cdata==i*2-1)) = minKL_mar2h_L(i);
    temp_human_r.cdata(find(atlas_human_r.cdata==i*2)) = minKL_mar2h_R(i);
end
save(temp_human_l, strcat(resultpath, 'minKL_indi_atlas/mar2h_Paxinos_minKL_on_human_atlas.L.func.gii'));
save(temp_human_r, strcat(resultpath, 'minKL_indi_atlas/mar2h_Paxinos_minKL_on_human_atlas.R.func.gii'));

save(strcat(resultpath, 'minKL_indi_atlas/mar2h_Paxinos_minKL_on_human_atlas.L.txt'), 'minKL_mar2h_L', '-ascii');
save(strcat(resultpath, 'minKL_indi_atlas/mar2h_Paxinos_minKL_on_human_atlas.R.txt'), 'minKL_mar2h_R', '-ascii');

save(strcat(resultpath, 'minKL_indi_atlas/mar2h_Paxinos_minKL_on_human_atlas_all_subject.L.mat'), 'minKL_mar2h_all_L');
save(strcat(resultpath, 'minKL_indi_atlas/mar2h_Paxinos_minKL_on_human_atlas_all_subject.R.mat'), 'minKL_mar2h_all_R');
