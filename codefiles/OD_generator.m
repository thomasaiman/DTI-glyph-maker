function [Xdata,Ydata,Zdata,color] = OD_generator(DT_mat,spherepoints,scalefactor)
% OD_generator  Takes a diffusion tensor matrix and the points of a
% sphere in desired resolution and outputs data and a RGB triplet.
% Scale factor changes how large the glyph is. DT_mat should be
% [Dxx Dxy Dxz; Dyx Dyy Dyz; Dzx Dzy Dzz]

%make DT = [Dxx Dxy Dxz Dyy Dyz Dzz]
DT([1 4 6]) = DT_mat([1 5 9]);
DT([2 3 5]) = (DT_mat([2 3 6])+DT_mat([4 7 8]))/2;


%calculate fractional anisotropy
e = eigs(DT_mat);
e(e<0) = 0;
e = real(e);
if ~any(e)
    e = ones(3,1);
end

em = mean(e);
fa = sqrt(3/2)*sqrt((e(1)-em).^2+(e(2)-em).^2+(e(3)-em).^2)./sqrt(e(1).^2+e(2).^2+e(3).^2);


OD = spherepoints.preOD * DT'/max(e);

% Remove negative values
OD(OD < 0) = 0; 
%normalization
OD = 1.2*sqrt(fa)*OD;

%find the point on the unit sphere (a.k.a the unit vector in
%that direction) which corresponds to the largest tensor
%change. This gives us an RGB color triplet of normalized
%brightness.
indx = find(OD==max(OD));
color = abs(spherepoints.colors_list(indx(1),:));

OD = reshape(OD,[(spherepoints.n)+1 (spherepoints.n)+1]);

Xdata = OD.* spherepoints.X *scalefactor;
Ydata = OD.* spherepoints.Y *scalefactor;
Zdata = OD.* spherepoints.Z *scalefactor;





