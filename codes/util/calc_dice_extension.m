datapath = '/n05dat/yfwang/user/MarmosetWM/result/af_xspecies/';

for lr=1:2
    if lr==1
        hemi = 'l';
    else
        hemi = 'r';
    end

    human = gifti(strcat(datapath, 'af_projection_registered/human_af_', hemi, '.func.gii'));
    macaque = gifti(strcat(datapath, 'af_projection_registered/macaque-to-human.af_', hemi, '.func.gii'));
    marmoset = gifti(strcat(datapath, 'af_projection_registered/marmoset-to-human.af_', hemi, '_edited.32k.func.gii'));
    
    %% Dice
    dice_human_macaque = size(find(human.cdata>0 & macaque.cdata>0),1) / (size(find(human.cdata>0),1)+size(find(macaque.cdata>0),1));
    dice_human_marmoset = size(find(human.cdata>0 & marmoset.cdata>0),1) / (size(find(human.cdata>0),1)+size(find(marmoset.cdata>0),1));
    
    disp(strcat('Dice human-macaque (', hemi, '):', num2str(dice_human_macaque)));
    disp(strcat('Dice human-marmoset (', hemi, '):', num2str(dice_human_marmoset)));
    
    %% Tract extension ratio
    extension_ratio_human_macaque = size(find(human.cdata>0),1) / size(find(human.cdata>0 & macaque.cdata>0),1);
    extension_ratio_human_marmoset = size(find(human.cdata>0),1) / size(find(human.cdata>0 & marmoset.cdata>0),1);
    
    disp(strcat('Tract extension ratio human-macaque (', hemi, '):', num2str(extension_ratio_human_macaque)));
    disp(strcat('Tract extension ratio human-marmoset (', hemi, '):', num2str(extension_ratio_human_marmoset)));
    
end