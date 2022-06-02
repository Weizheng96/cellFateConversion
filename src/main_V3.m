
%% based on curvature score difference
%% 

%% parameters
datPath="E:\Project\ZhirongWang\data\3D\examples\dat_2.mat";
minSz = 50;
maxSz = 1000000;
smoothingfactor=2;
p=0.05;
detectionThreshold=1;
%% addpath 
srcPath = fileparts(which('main.m')); 
addpath(genpath(srcPath));
%% read data
load(datPath);
dat=double(dat_crop);
im=visDataMaxPro(dat);
implay(im);
%% detection
[BgThr1,NoiseLv1]=foreIntensityThreshold(dat(:,:,:,:,1),p);
[BgThr2,NoiseLv2]=foreIntensityThreshold(dat(:,:,:,:,2),p);
[X,Y,Z,T,~]=size(dat);
diffIntMap=zeros(size(dat));
parfor t=1:T
    disp("channel 1: "+t+"/"+T);
    diffIntMap(:,:,:,t,1) = synquant_curvatureDiff(dat(:,:,:,t,1),BgThr1,minSz, maxSz,smoothingfactor);
end
parfor t=1:T
    disp("channel 2: "+t+"/"+T);
    diffIntMap(:,:,:,t,2) = synquant_curvatureDiff(dat(:,:,:,t,2),BgThr2,minSz, maxSz,smoothingfactor);
end

%% display
DtMap=zeros(size(diffIntMap));
DtMap(:,:,:,:,1)=diffIntMap(:,:,:,:,1)>NoiseLv1*detectionThreshold;
DtMap(:,:,:,:,2)=diffIntMap(:,:,:,:,2)>NoiseLv2*detectionThreshold;
imOut1=visDataMaxPro(dat);
imOut2=visDataMaxPro(DtMap);
imOut3=visDataMaxPro(min(diffIntMap,20));
imOut=cat(2,imOut1,imOut2,imOut3);
implay(imOut)

%%
implay(squeeze(mat2gray(dat(:,:,:,18,1))))
imagesc(squeeze(dat(:,:,15,18,1)))

imagesc(squeeze(diffIntMap(:,:,15,18,1)))


a=dat(:,:,:,18,1);
b=a>BgThr1;
implay(b);
maskroi = bwlabeln(b);
maskroiIDx = label2idx(maskroi);
for i=1:length(maskroiIDx)
    c(i)=length(maskroiIDx{i});
end
plot(c)