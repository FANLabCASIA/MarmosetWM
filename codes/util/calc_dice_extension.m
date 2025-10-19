addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/GIFTI'));
addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/NIFTI'));

resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/af_projection_registration/';

subs_human = textread('/gpfs/userdata/yfwang/preprocess_fsl/human/humanlist40.txt', '%s');
subs_macaque = textread('/gpfs/userdata/yfwang/preprocess_fsl/macaque_tvb/macaque_tvb_list.txt', '%s');
subs_marmoset = textread('/gpfs/userdata/yfwang/MarmosetWM/support_data/marmoset_MBM_list.txt', '%s');

%% human vs macaque
dice_human_macaque_L = zeros(length(subs_human), length(subs_macaque));
dice_human_macaque_R = zeros(length(subs_human), length(subs_macaque));

extension_ratio_human_macaque_L = zeros(length(subs_human), length(subs_macaque));
extension_ratio_human_macaque_R = zeros(length(subs_human), length(subs_macaque));

for h=1:length(subs_human)
    for m=1:length(subs_macaque)

        af_human_l = gifti(strcat(resultpath, 'af_projection_registration_indi/human/', subs_human{h}, '/', subs_human{h}, '_af_l_thr0_norm_thres.func.gii'));
        af_human_r = gifti(strcat(resultpath, 'af_projection_registration_indi/human/', subs_human{h}, '/', subs_human{h}, '_af_r_thr0_norm_thres.func.gii'));

        af_macaque_l = gifti(strcat(resultpath, 'af_projection_registration_indi/macaque_tvb/', subs_macaque{m}, '/', subs_macaque{m}, '-human_af_l_thr0_norm_thres.func.gii'));
        af_macaque_r = gifti(strcat(resultpath, 'af_projection_registration_indi/macaque_tvb/', subs_macaque{m}, '/', subs_macaque{m}, '-human_af_r_thr0_norm_thres.func.gii'));

        % Dice
        dice_human_macaque_L(h, m) = size(find(af_human_l.cdata>0 & af_macaque_l.cdata>0),1) / (size(find(af_human_l.cdata>0),1)+size(find(af_macaque_l.cdata>0),1));
        dice_human_macaque_R(h, m) = size(find(af_human_r.cdata>0 & af_macaque_r.cdata>0),1) / (size(find(af_human_r.cdata>0),1)+size(find(af_macaque_r.cdata>0),1));

        % extension ratio
        extension_ratio_human_macaque_L(h, m) = size(find(af_human_l.cdata>0),1) / size(find(af_human_l.cdata>0 & af_macaque_l.cdata>0),1);
        extension_ratio_human_macaque_R(h, m) = size(find(af_human_r.cdata>0),1) / size(find(af_human_r.cdata>0 & af_macaque_r.cdata>0),1);
    end
end

save(strcat(resultpath, 'dice_extension/dice_human_macaque_l.txt'), 'dice_human_macaque_L', '-ascii');
save(strcat(resultpath, 'dice_extension/dice_human_macaque_r.txt'), 'dice_human_macaque_R', '-ascii');

save(strcat(resultpath, 'dice_extension/extension_ratio_human_macaque_l.txt'), 'extension_ratio_human_macaque_L', '-ascii');
save(strcat(resultpath, 'dice_extension/extension_ratio_human_macaque_r.txt'), 'extension_ratio_human_macaque_R', '-ascii');


%% human vs marmoset
dice_human_marmoset_L = zeros(length(subs_human), length(subs_marmoset));
dice_human_marmoset_R = zeros(length(subs_human), length(subs_marmoset));

extension_ratio_human_marmoset_L = zeros(length(subs_human), length(subs_marmoset));
extension_ratio_human_marmoset_R = zeros(length(subs_human), length(subs_marmoset));

for h=1:length(subs_human)
    for m=1:length(subs_marmoset)

        af_human_l = gifti(strcat(resultpath, 'af_projection_registration_indi/human/', subs_human{h}, '/', subs_human{h}, '_af_l_thr0_norm_thres.func.gii'));
        af_human_r = gifti(strcat(resultpath, 'af_projection_registration_indi/human/', subs_human{h}, '/', subs_human{h}, '_af_r_thr0_norm_thres.func.gii'));

        af_marmoset_l = gifti(strcat(resultpath, 'af_projection_registration_indi/marmoset_MBM/', subs_marmoset{m}, '/', subs_marmoset{m}, '-human_af_l_thr0_norm_thres.func.gii'));
        af_marmoset_r = gifti(strcat(resultpath, 'af_projection_registration_indi/marmoset_MBM/', subs_marmoset{m}, '/', subs_marmoset{m}, '-human_af_r_thr0_norm_thres.func.gii'));

        % Dice
        dice_human_marmoset_L(h, m) = size(find(af_human_l.cdata>0 & af_marmoset_l.cdata>0),1) / (size(find(af_human_l.cdata>0),1)+size(find(af_marmoset_l.cdata>0),1));
        dice_human_marmoset_R(h, m) = size(find(af_human_r.cdata>0 & af_marmoset_r.cdata>0),1) / (size(find(af_human_r.cdata>0),1)+size(find(af_marmoset_r.cdata>0),1));

        % extension ratio
        extension_ratio_human_marmoset_L(h, m) = size(find(af_human_l.cdata>0),1) / size(find(af_human_l.cdata>0 & af_marmoset_l.cdata>0),1);
        extension_ratio_human_marmoset_R(h, m) = size(find(af_human_r.cdata>0),1) / size(find(af_human_r.cdata>0 & af_marmoset_r.cdata>0),1);
    end
end

save(strcat(resultpath, 'dice_extension/dice_human_marmoset_l.txt'), 'dice_human_marmoset_L', '-ascii');
save(strcat(resultpath, 'dice_extension/dice_human_marmoset_r.txt'), 'dice_human_marmoset_R', '-ascii');

save(strcat(resultpath, 'dice_extension/extension_ratio_human_marmoset_l.txt'), 'extension_ratio_human_marmoset_L', '-ascii');
save(strcat(resultpath, 'dice_extension/extension_ratio_human_marmoset_r.txt'), 'extension_ratio_human_marmoset_R', '-ascii');