function im=visData(dat,t)

r=dat(:,:,:,t,2);
r=mat2gray(r);
g=dat(:,:,:,t,1);
g=mat2gray(g);
b=zeros(size(r));
im=cat(4,r,g,b);
im=permute(im,[1 2 4 3]);


end