clear all
close all
[a,b,c] = sphere(100);

a = a(:);
b = b(:);
c = c(:);

s = [a';b';c'];

l1 = [1;2;3];
l2 = [0;2;0];
l3 = [0;0;3];

E = [l1,l2,l3]

elps = E*s;

elps = elps';

elps = reshape(elps,101,101,3);

x = squeeze(elps(:,:,1));
y = squeeze(elps(:,:,2));
z = squeeze(elps(:,:,3));

surf(x,y,z)
axis equal

figure
[e,v] = eigs(E');
elps2 = e*v*s;
elps2 = reshape(elps2,101,101,3);

x2 = squeeze(elps2(:,:,1));
y2 = squeeze(elps2(:,:,2));
z2 = squeeze(elps2(:,:,3));
surf(x2,y2,z2)
axis equal