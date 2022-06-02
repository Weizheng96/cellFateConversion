dat_c=max(dat,[],3);
dat_cc(:,:,:,:,1)=dat_cc(:,:,:,:,1)*2;
dat_cc=cat(5,dat_c,zeros(size(dat_c,[1 2 3 4])));
dat_ccc=squeeze(permute(dat_cc,[1 2 3 5 4]));
dat_v=mat2gray(double(dat_ccc));
implay(dat_v*5)

x=100:400;
y=450:650;
implay(dat_v(x,y,:,:)*5)

dat_crop=dat(x,y,:,:,:);
save("dat_3","dat_crop","x","y")