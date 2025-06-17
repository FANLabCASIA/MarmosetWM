function r=surflocalcorr(x,y,sph,a)
% r=surflocalcorr(x,y,sph,[angle=10])
% local correlations between x and y on the spherical surface sph
%
% S.Jbabdi 03/13
if(nargin<3);
    addpath /home/fs0/saad/matlab/CIFTIMatlabReaderWriter_old/
    sph=gifti('/vols/Scratch/saad/example_gifti_cifti/L.sphere.surf.gii');
    a=10;
end
if(nargin<4);
    if(isempty(sph))
        addpath /home/fs0/saad/matlab/CIFTIMatlabReaderWriter_old/
        sph=gifti('/vols/Scratch/saad/example_gifti_cifti/L.sphere.surf.gii');
    end
    a=10;
end

v=sph.vertices;
v=v./repmat(sqrt(sum(v.^2,2)),1,3);
r=0*v(:,1);
vals=~~x&~~y;
for i=1:size(v,1)
    j=(acosd(v*v(i,:)')<a) & vals;
    if(sum(j)>30)
        c=corrcoef(x(j),y(j));
        r(i)=c(1,2);
    end
end
r(~vals)=0;
