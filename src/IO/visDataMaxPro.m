function im=visDataMaxPro(dat)
im=zeros([size(dat,[1 2]) 3 size(dat,4)]);
for t=1:size(dat,4)
    r=dat(:,:,:,t,2);
    r=max(r,[],3);
    r=mat2gray(r);
    g=dat(:,:,:,t,1);
    g=max(g,[],3);
    g=mat2gray(g);
    b=zeros(size(r));
    im(:,:,:,t)=cat(3,r,g,b);
end
% implay(im);

end