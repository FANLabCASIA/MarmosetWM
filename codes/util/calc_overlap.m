datapath = '/n05dat/yfwang/user/MarmosetWM/result/af_xspecies/';

for lr=1:2
    if lr==1
        hemi = 'l';
    else
        hemi = 'r';
    end

    human = gifti(strcat(datapath, 'af_projection_registered/human_af_', hemi, '.func.gii'));
    macaque = gifti(strcat(datapath, 'af_projection_registered/macaque-to-human.af_', hemi, '.func.gii'));
    marmoset = gifti(strcat(datapath, 'af_projection_registered/marmoset-to-human.af_', hemi, '.32k.func.gii'));

    human.cdata(find(human.cdata>0)) = 1;
    macaque.cdata(find(macaque.cdata>0)) = 1;
    marmoset.cdata(find(marmoset.cdata>0)) = 1;

    save(human, strcat(datapath, 'af_projection_registered_bin/human_af_', hemi, '_bin.func.gii'));
    save(macaque, strcat(datapath, 'af_projection_registered_bin/macaque_af_', hemi, '_bin.func.gii'));
    save(marmoset, strcat(datapath, 'af_projection_registered_bin/marmoset_af_', hemi, '_bin.func.gii'));

    temp = gifti(strcat(datapath, 'af_projection_registered/human_af_', hemi, '.func.gii'));
    temp.cdata = zeros(size(temp.cdata));
    for i=0:1
        for j=0:1
            for k=0:1
                temp.cdata(find(human.cdata==i & macaque.cdata==j & marmoset.cdata==k)) = i*4+j*2+k*1;
            end
        end
    end
    save(temp, strcat(datapath, 'af_projection_registered_bin/overlap_af_', hemi, '.func.gii'));
end
