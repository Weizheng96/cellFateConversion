
%% 
%% 

%% parameters
datPath="E:\Project\ZhirongWang\data\3D\examples\dat_2.mat";
minSz = 50;
maxSz = 100000;
smoothingfactor=2;
p=0.05;
detectionThreshold=3;
%% addpath 
srcPath = fileparts(which('main.m')); 
addpath(genpath(srcPath));
%% read data
load(datPath);
dat=double(dat_crop);
im=visDataMaxPro(dat);
implay(im);

im=visDataMaxPro(dat);
implay(mat2gray(dat(:,:,:,1,2)));
%% detection
[X,Y,Z,T,~]=size(dat);
ZMap=zeros(size(dat));
MuLst=zeros(2,1);SigmaLst=zeros(2,1);
tic
for channel=1:2
    [Mu,Sigma]=estimateNoise(dat(:,:,:,:,channel));
    MuLst(channel)=Mu;SigmaLst(channel)=Sigma;
    parfor t=1:T
        disp("channel "+channel+": "+t+"/"+T);
%         ZMap(:,:,:,t,channel) = synquant_org(dat(:,:,:,t,channel),minSz,smoothingfactor,Mu,Sigma);
        ZMap(:,:,:,t,channel) = synquant_biggest(dat(:,:,:,t,channel),minSz,smoothingfactor,Mu,Sigma);
    end
end
toc

DtMap=zeros(size(ZMap));
DtMap(:,:,:,:,1)=ZMap(:,:,:,:,1)>detectionThreshold;
DtMap(:,:,:,:,2)=ZMap(:,:,:,:,2)>detectionThreshold;
%% display

imOut1=visDataMaxPro(dat);
imOut2=visDataMaxPro(DtMap);
imOut3=visDataMaxPro(min(ZMap,20));
imOut=cat(2,imOut1,imOut2,imOut3);
implay(imOut) 

%%
t=400;
imOut1=visData(dat,t);
imOut2=visData(DtMap,t);
imOut3=visData(min(ZMap,20),t);
imOut=cat(2,imOut1,imOut2,imOut3);
implay(imOut) 