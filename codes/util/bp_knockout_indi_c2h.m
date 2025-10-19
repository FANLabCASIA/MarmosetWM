%% human vs. chimp

resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/connectivity_divergence/';
supportdatapath = '/gpfs/userdata/yfwang/MarmosetWM/support_data/';

%% load data
fibers = {'AC', 'AF', 'AR', 'ATR', 'CBD', 'CBP', 'CBT', 'CST', ...
          'FA', 'FX', 'IFOF', 'ILF', 'MDLF', 'OR', 'PTR', 'SLF1', ...
          'SLF2', 'SLF3', 'STR', 'UF', 'VOF', 'FMA', 'FMI', 'MCP', ...
          'ALL'};
fiber_index_l = [1,3,5,7,9,11,13,15,17,21,42,44,24,26,28,30,32,34,36,38,40,19,20,23];
fiber_index_r = [2,4,6,8,10,12,14,16,18,22,43,45,25,27,29,31,33,35,37,39,41,19,20,23];

fiber_interest = [2,4,18,20, 25];
% AF:2, ATR:4, SLF3:18, UF:20, ALL:25

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

% calculate minKL between human and chimp (subject level)
subs_human = textread('humanlist40.txt', '%s');
subs_chimp = textread('chimplist46.txt', '%s');


%% calculate minKL for each subject pair and each tract
minKL_c2h_all_L = zeros(length(subs_human), length(subs_chimp), 105, length(fiber_interest));
minKL_c2h_all_R = zeros(length(subs_human), length(subs_chimp), 105, length(fiber_interest));

for h=1:length(subs_human)
    for m=1:length(subs_chimp)
        disp(strcat(num2str(h), '-', num2str(m)));
        
        bp_human_l = load(strcat(resultpath, 'bp_atlas_indi/human/', subs_human{h}, '_BP_atlas.L.txt'));
        bp_human_r = load(strcat(resultpath, 'bp_atlas_indi/human/', subs_human{h}, '_BP_atlas.R.txt'));
        bp_human_l = bp_human_l(:,fiber_index_l);
        bp_human_r = bp_human_r(:,fiber_index_r);
        
        bp_chimp_l = load(strcat(resultpath, 'bp_atlas_indi/chimp/', subs_chimp{m}, '_BP_atlas.L.txt'));
        bp_chimp_r = load(strcat(resultpath, 'bp_atlas_indi/chimp/', subs_chimp{m}, '_BP_atlas.R.txt'));
        bp_chimp_l = bp_chimp_l(:,fiber_index_l);
        bp_chimp_r = bp_chimp_r(:,fiber_index_r);        
        
        % KL with leave-one-out tract
        for f=1:length(fiber_interest)-1
            
            bp_human_l_loo = bp_human_l;
            bp_human_l_loo(:, fiber_interest(f)) = [];
            
            bp_human_r_loo = bp_human_r;
            bp_human_r_loo(:, fiber_interest(f)) = [];
            
            bp_chimp_l_loo = bp_chimp_l;
            bp_chimp_l_loo(:, fiber_interest(f)) = [];
            
            bp_chimp_r_loo = bp_chimp_r;
            bp_chimp_r_loo(:, fiber_interest(f)) = [];
            
            KL_L = calc_KL(bp_human_l_loo, bp_chimp_l_loo);
            [minKL_c2h_all_L(h, m, :, f), ~] = min(KL_L,[],2);
            
            KL_R = calc_KL(bp_human_r_loo, bp_chimp_r_loo);
            [minKL_c2h_all_R(h, m, :, f), ~] = min(KL_R,[],2);
        end
        
        % KL with ALL tracts
        KL_L = calc_KL(bp_human_l, bp_chimp_l);
        [minKL_c2h_all_L(h, m, :, length(fiber_interest)), ~] = min(KL_L,[],2);
        
        KL_R = calc_KL(bp_human_r, bp_chimp_r);
        [minKL_c2h_all_R(h, m, :, length(fiber_interest)), ~] = min(KL_R,[],2);
    end
end

save(strcat(resultpath, 'knockout_indi/c2h_minKL_on_human_atlas_all_subject.L.mat'), 'minKL_c2h_all_L');
save(strcat(resultpath, 'knockout_indi/c2h_minKL_on_human_atlas_all_subject.R.mat'), 'minKL_c2h_all_R');


%% calculate average minKL across subjects for each tract
for f=1:length(fiber_interest)
    
    minKL_c2h_L = squeeze(mean(mean(minKL_c2h_all_L)));
    minKL_c2h_R = squeeze(mean(mean(minKL_c2h_all_R)));
    
    minKL_c2h_L = minKL_c2h_L(:,f);
    minKL_c2h_R = minKL_c2h_R(:,f);
    
    temp_human_l.cdata = zeros(size(temp_human_l.cdata));
    temp_human_r.cdata = zeros(size(temp_human_r.cdata));
    for i=1:105
        temp_human_l.cdata(find(atlas_human_l.cdata==i*2-1)) = minKL_c2h_L(i);
        temp_human_r.cdata(find(atlas_human_r.cdata==i*2)) = minKL_c2h_R(i);
    end
    save(temp_human_l, strcat(resultpath, 'knockout_indi/c2h_minKL_on_human_atlas_', fibers{fiber_interest(f)}, '.L.func.gii'));
    save(temp_human_r, strcat(resultpath, 'knockout_indi/c2h_minKL_on_human_atlas_', fibers{fiber_interest(f)}, '.R.func.gii'));

    save(strcat(resultpath, 'knockout_indi/c2h_minKL_on_human_atlas_', fibers{fiber_interest(f)}, '.L.txt'), 'minKL_c2h_L', '-ascii');
    save(strcat(resultpath, 'knockout_indi/c2h_minKL_on_human_atlas_', fibers{fiber_interest(f)}, '.R.txt'), 'minKL_c2h_R', '-ascii');
end


%% calculate deltaKL for each tract
deltaKL_c2h_A45c_L = zeros(length(subs_human), length(subs_chimp), length(fiber_interest)-1);
deltaKL_c2h_A45c_R = zeros(length(subs_human), length(subs_chimp), length(fiber_interest)-1);

for f=1:length(fiber_interest)-1
   
    deltaKL_c2h_A45c_L(:,:,f) = abs(minKL_c2h_all_L(:,:,17,f) - minKL_c2h_all_L(:,:,17,5));
    deltaKL_c2h_A45c_R(:,:,f) = abs(minKL_c2h_all_R(:,:,17,f) - minKL_c2h_all_R(:,:,17,5));

end

save(strcat(resultpath, 'knockout_indi/c2h_deltaKL_on_human_atlas_A45c.L.mat'), 'deltaKL_c2h_A45c_L');
save(strcat(resultpath, 'knockout_indi/c2h_deltaKL_on_human_atlas_A45c.R.mat'), 'deltaKL_c2h_A45c_R');

minKL_c2h_A45c_L = squeeze(minKL_c2h_all_L(:,:,17,:));
minKL_c2h_A45c_R = squeeze(minKL_c2h_all_R(:,:,17,:));

save(strcat(resultpath, 'knockout_indi/c2h_minKL_on_human_atlas_A45c.L.mat'), 'minKL_c2h_A45c_L');
save(strcat(resultpath, 'knockout_indi/c2h_minKL_on_human_atlas_A45c.R.mat'), 'minKL_c2h_A45c_R');
