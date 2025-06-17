addpath('/n02dat01/users/yfwang/software/MatlabToolbox/GIFTI/');

fibers = {'AC', 'AF', 'AR', 'ATR', 'CBD', 'CBP', 'CBT', 'CST', 'FA',   'FX',   'IFOF', 'ILF',   'MDLF', 'OR', 'PTR', 'SLF1', 'SLF2', 'SLF3', 'STR', 'UF', 'VOF', 'FMA', 'FMI'};
fiber_index_l = [1,3,5,7,9,11,13,15,17,21,42,44,24,26,28,30,32,34,36,38,40,19,20];
fiber_index_r = [2,4,6,8,10,12,14,16,18,22,43,45,25,27,29,31,33,35,37,39,41,19,20];

WD = '/n02dat01/users/yfwang/MarmosetWM/result/bp_xspecies/';

bp_human_l = load(strcat(WD, 'bp_4species/human40_BP_atlas.L.mat'));
bp_human_r = load(strcat(WD, 'bp_4species/human40_BP_atlas.R.mat'));
bp_chimp_l = load(strcat(WD, 'bp_4species/chimp46_BP_atlas.L.mat'));
bp_chimp_r = load(strcat(WD, 'bp_4species/chimp46_BP_atlas.R.mat'));
bp_macaque_l = load(strcat(WD, 'bp_4species/macaque8_BP_atlas.L.mat'));
bp_macaque_r = load(strcat(WD, 'bp_4species/macaque8_BP_atlas.R.mat'));
bp_marmoset_l = load(strcat(WD, 'bp_4species/marmoset24_BP_atlas.L.mat'));
bp_marmoset_r = load(strcat(WD, 'bp_4species/marmoset24_BP_atlas.R.mat'));

bp_human_l = bp_human_l.bp_atlas_l(:,fiber_index_l);
bp_human_r = bp_human_r.bp_atlas_r(:,fiber_index_r);
bp_chimp_l = bp_chimp_l.bp_atlas_l(:,fiber_index_l);
bp_chimp_r = bp_chimp_r.bp_atlas_r(:,fiber_index_r);
bp_macaque_l = bp_macaque_l.bp_atlas_l(:,fiber_index_l);
bp_macaque_r = bp_macaque_r.bp_atlas_r(:,fiber_index_r);
bp_marmoset_l = bp_marmoset_l.bp_atlas_l(:,fiber_index_l);
bp_marmoset_r = bp_marmoset_r.bp_atlas_r(:,fiber_index_r);

bp_human_l = bp_human_l ./ repmat(sum(bp_human_l,2),1,23);
bp_human_r = bp_human_r ./ repmat(sum(bp_human_r,2),1,23);
bp_chimp_l = bp_chimp_l ./ repmat(sum(bp_chimp_l,2),1,23);
bp_chimp_r = bp_chimp_r ./ repmat(sum(bp_chimp_r,2),1,23);
bp_macaque_l = bp_macaque_l ./ repmat(sum(bp_macaque_l,2),1,23);
bp_macaque_r = bp_macaque_r ./ repmat(sum(bp_macaque_r,2),1,23);
bp_marmoset_l = bp_marmoset_l ./ repmat(sum(bp_marmoset_l,2),1,23);
bp_marmoset_r = bp_marmoset_r ./ repmat(sum(bp_marmoset_r,2),1,23);

KL_human_chimp_L = calc_KL(bp_human_l, bp_chimp_l);
[minKL_human_chimp_L, index_human_chimp_L] = min(KL_human_chimp_L,[],2);
KL_human_macaque_L = calc_KL(bp_human_l, bp_macaque_l);
[minKL_human_macaque_L, index_human_macaque_L] = min(KL_human_macaque_L,[],2);
KL_human_marmoset_L = calc_KL(bp_human_l, bp_marmoset_l);
[minKL_human_marmoset_L, index_human_marmoset_L] = min(KL_human_marmoset_L,[],2);

save(strcat(WD, 'minKL_loo/minKL_human_chimp_L_ALL.txt'), 'minKL_human_chimp_L', '-ascii');
save(strcat(WD, 'minKL_loo/minKL_human_macaque_L_ALL.txt'), 'minKL_human_macaque_L', '-ascii');
save(strcat(WD, 'minKL_loo/minKL_human_marmoset_L_ALL.txt'), 'minKL_human_marmoset_L', '-ascii');

for i=1:length(fiber_index_l)

    bp_human_l_loo = bp_human_l;
    bp_human_l_loo(:,i) = [];
    bp_chimp_l_loo = bp_chimp_l;
    bp_chimp_l_loo(:,i) = [];
    bp_macaque_l_loo = bp_macaque_l;
    bp_macaque_l_loo(:,i) = [];
    bp_marmoset_l_loo = bp_marmoset_l;
    bp_marmoset_l_loo(:,i) = [];
    
    % find new min ROI
    KL_human_chimp_L = calc_KL(bp_human_l_loo, bp_chimp_l_loo);
    [minKL_human_chimp_L_loo(:,i), ~] = min(KL_human_chimp_L,[],2);
    KL_human_macaque_L = calc_KL(bp_human_l_loo, bp_macaque_l_loo);
    [minKL_human_macaque_L_loo(:,i), ~] = min(KL_human_macaque_L,[],2);
    KL_human_marmoset_L = calc_KL(bp_human_l_loo, bp_marmoset_l_loo);
    [minKL_human_marmoset_L_loo(:,i), ~] = min(KL_human_marmoset_L,[],2);
    
    minKL_human_chimp_tmp = minKL_human_chimp_L_loo(:,i);
    minKL_human_macaque_tmp = minKL_human_macaque_L_loo(:,i);
    minKL_human_marmoset_tmp = minKL_human_marmoset_L_loo(:,i);
    
    save(strcat(WD, 'minKL_loo/minKL_human_chimp_L_', fibers{i}, '.txt'), 'minKL_human_chimp_tmp', '-ascii');
    save(strcat(WD, 'minKL_loo/minKL_human_macaque_L_', fibers{i}, '.txt'), 'minKL_human_macaque_tmp', '-ascii');
    save(strcat(WD, 'minKL_loo/minKL_human_marmoset_L_', fibers{i}, '.txt'), 'minKL_human_marmoset_tmp', '-ascii');
end

%% compare minKL before and after knocking out AF
[h,p] = kstest2(minKL_human_chimp_L_loo(:,2), minKL_human_chimp_L);
disp(strcat('By knocking out AF, p-value between distribution = ', num2str(p)));
[h,p] = kstest2(minKL_human_macaque_L_loo(:,2), minKL_human_macaque_L);
disp(strcat('By knocking out AF, p-value between distribution = ', num2str(p)));
[h,p] = kstest2(minKL_human_marmoset_L_loo(:,2), minKL_human_marmoset_L);
disp(strcat('By knocking out AF, p-value between distribution = ', num2str(p)));

temp_l = gifti('/n02dat01/users/yfwang/MarmosetWM/support_data/atlas/human/100307.L.atlasroi.32k_fs_LR.shape.gii'));
temp_r = gifti('/n02dat01/users/yfwang/MarmosetWM/support_data/atlas/human/100307.R.atlasroi.32k_fs_LR.shape.gii'));
atlas_l = gifti('/n02dat01/users/yfwang/MarmosetWM/support_data/atlas/human/fsaverage.L.BN_Atlas.32k_fs_LR.label.gii'));
atlas_r = gifti('/n02dat01/users/yfwang/MarmosetWM/support_data/atlas/human/fsaverage.R.BN_Atlas.32k_fs_LR.label.gii'));

temp_l.cdata = zeros(size(temp_l.cdata));
% temp_r.cdata = zeros(size(temp_r.cdata));
for i=1:105
    temp_l.cdata(find(atlas_l.cdata==i*2-1)) = minKL_human_macaque_L_loo(i,2);
%     temp_r.cdata(find(atlas_r.cdata==i*2)) = minKL_human_macaque_R_loo(i,2);
end
save(temp_l, strcat(WD, 'minKL_loo/minKL_human_macaque_L_af.func.gii'));
% save(temp_r, strcat(WD, 'minKL_loo/minKL_human_macaque_R_af.func.gii'));

temp_l.cdata = zeros(size(temp_l.cdata));
% temp_r.cdata = zeros(size(temp_r.cdata));
for i=1:105
    temp_l.cdata(find(atlas_l.cdata==i*2-1)) = minKL_human_chimp_L_loo(i,2);
%     temp_r.cdata(find(atlas_r.cdata==i*2)) = minKL_human_chimp_R_loo(i,2);
end
save(temp_l, strcat(WD, 'minKL_loo/minKL_human_chimp_L_af.func.gii'));
% save(temp_r, strcat(WD, 'minKL_loo/minKL_human_chimp_R_af.func.gii'));

temp_l.cdata = zeros(size(temp_l.cdata));
% temp_r.cdata = zeros(size(temp_r.cdata));
for i=1:105
    temp_l.cdata(find(atlas_l.cdata==i*2-1)) = minKL_human_marmoset_L_loo(i,2);
%     temp_r.cdata(find(atlas_r.cdata==i*2)) = minKL_human_marmoset_R_loo(i,2);
end
save(temp_l, strcat(WD, 'minKL_loo/minKL_human_marmoset_L_af.func.gii'));
% save(temp_r, strcat(WD, 'minKL_loo/minKL_human_marmoset_R_af.func.gii'));

%% 
roi_index = 17;
deltaKL_human_chimp_L = minKL_human_chimp_L_loo(roi_index,:) - minKL_human_chimp_L(roi_index);
deltaKL_human_macaque_L = minKL_human_macaque_L_loo(roi_index,:) - minKL_human_macaque_L(roi_index);
deltaKL_human_marmoset_L = minKL_human_marmoset_L_loo(roi_index,:) - minKL_human_marmoset_L(roi_index);

disp(strcat('human-chimp: before minKL=', num2str(minKL_human_chimp_L(roi_index)), '; after minKL=', num2str(minKL_human_chimp_L_loo(roi_index,2))));
disp(strcat('human-macaque: before minKL=', num2str(minKL_human_macaque_L(roi_index)), '; after minKL=', num2str(minKL_human_macaque_L_loo(roi_index,2))));
disp(strcat('human-marmoset: before minKL=', num2str(minKL_human_marmoset_L(roi_index)), '; after minKL=', num2str(minKL_human_marmoset_L_loo(roi_index,2))));

disp(strcat('human-chimp: before minKL=', num2str(deltaKL_human_chimp_L(2))));
disp(strcat('human-macaque: before minKL=', num2str(deltaKL_human_macaque_L(2))));
disp(strcat('human-marmoset: before minKL=', num2str(deltaKL_human_marmoset_L(2))));
