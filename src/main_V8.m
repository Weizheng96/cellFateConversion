%% 3D global threshold + principal curvature + watershed
%% need large memory
clear; close all;

%% parameters
sampleCnt=2;
datafolderPath="E:\Project\ZhirongWang\data\3D\examples";
datPath=datafolderPath+"/dat_"+sampleCnt+".mat";
minSz = 500;
maxSz = 1000000;
smoothingfactor=3;
Zratio=3;
detectionThreshold=3;
%% addpath 
Version="0602";
srcPath = fileparts(which('main_V8.m')); 
addpath(genpath(srcPath));
%% read data
load(datPath);
dat_crop=double(dat_crop);
[X,Y,Z,T,C]=size(dat_crop);
dat=zeros(X,Y,Z*Zratio,T,C);
for channel=1:2
    parfor t=1:T
        disp("Smooth:"+channel+":"+t);
        dat(:,:,:,t,channel)=imresize3(dat_crop(:,:,:,t,channel),[X,Y,Z*Zratio]);
    end
end
clear dat_crop;
%% detection
[X,Y,Z,T,~]=size(dat);
ZMap=zeros(size(dat));
MuLst=zeros(2,1);SigmaLst=zeros(2,1);
datSmo=zeros(size(dat));

for channel=1:2
    [Mu,Sigma]=estimateNoise(dat(:,:,:,:,channel));
    MuLst(channel)=Mu;SigmaLst(channel)=Sigma;
    parfor t=1:T
        disp("Foreground:"+channel+":"+t);
        datSmo(:,:,:,t,channel)=imgaussfilt3(dat(:,:,:,t,channel),smoothingfactor);
    end
    ZMap(:,:,:,:,channel)=(datSmo(:,:,:,:,channel)-Mu)/Sigma;
end
DtMap=ZMap>detectionThreshold;
clear datSmo;
%%
datPC=zeros(size(dat));
for channel=1:2
    Mu=MuLst(channel);Sigma=SigmaLst(channel);
    parfor t=1:T
        disp("Get PC:"+channel+":"+t);
        datPC(:,:,:,t,channel) = principalCurvature3d(dat(:,:,:,t,channel),smoothingfactor,DtMap(:,:,:,t,channel));
    end
end
PC_seed=datPC<0;
clear dat;
%%
% implay(mat2gray(datPC(:,:,:,246,1)))
% implay(mat2gray(dat(:,:,:,246,1)))
% implay(mat2gray(PC_seed(:,:,:,246,1)))

%% refine by PC
smoothingfactor_2D=smoothingfactor(1);
SE_large = ones(smoothingfactor*2+1);


cellMap_PCrefine=zeros(size(PC_seed));

for channel=1:2
    parfor t=1:T
        disp("Watershed:"+channel+":"+t);
        L=PC_seed(:,:,:,t,channel);
        L=bwlabeln(L);
        L=rmCC_bandPass(L,minSz,maxSz);
        
        bg=~DtMap(:,:,:,t,channel);
        bg=imerode(bg,SE_large);
        L(bg)=1;
        
        L = splitROIbyWtrshd3D(ones(size(L)),L,datPC(:,:,:,t,channel));
        cellMap_PCrefine(:,:,:,t,channel)=rmCC_bandPass(L,minSz,maxSz);
    end
end

clear datPC;
clear DtMap;
%% resize
load(datPath);
dat=double(dat_crop);
[X,Y,Z,T,C]=size(dat);
cellMap=zeros(X,Y,Z,T,C);
for channel=1:2
    parfor t=1:T
        disp("Resize:"+channel+":"+t);
        cellMap(:,:,:,t,channel)=imresize3(cellMap_PCrefine(:,:,:,t,channel),[X,Y,Z],'nearest');
    end
end
clear dat_crop cellMap_PCrefine;
%% display detection
% imOut1=visDataVideo(dat2D);
% imOut2=visDataVideo(cellMap_PCrefine);
% imOut=cat(2,imOut1,imOut2);
% implay(imOut) 
% implay(mat2gray(double(linkMap(:,:,:,200,1))))
%% link
linkMap=zeros(X,Y,Z,T,2,"uint16");
for channel=1:2
    detection_refined=cellMap(:,:,:,:,channel);
    [ID_loc2glo,ID_glo2loc,DetectionNumLst]=sortDetection(detection_refined);
    [trackG,para,DetectionRegion]=buildGraph2(ID_loc2glo,ID_glo2loc,detection_refined);
    [res_G, trajectories] = sspTracker(trackG, para);
    
    SZ=size(detection_refined);
    SZframe=SZ(1)*SZ(2)*SZ(3);
    detection_linked=zeros(SZ,"uint16");
    Ntrace=uint16(length(trajectories));
    for cnt=1:Ntrace
        disp("trace to detection:"+cnt);
        traceTemp=trajectories{cnt};
        for i=1:length(traceTemp)
            IDloc=ID_glo2loc(traceTemp(i),:);
    %         idxLoc=find(detection_refined(:,:,:,IDloc(1))==IDloc(2));
            idxLoc=DetectionRegion{traceTemp(i)};
            idxGlo=idxLoc+SZframe*(IDloc(1)-1);
            detection_linked(idxGlo)=cnt;
        end
    end
    linkMap(:,:,:,:,channel)=detection_linked;
end

clear cellMap;
%%
disp("Write tif...");
imOut1=uint8(visDataVideo3D(dat)*255);
imOut2=uint8(visDataVideo3D(double(linkMap),"colorful"));
imOut=cat(2,imOut1,imOut2);
cd(datafolderPath);
write4dTiffRGB(imOut,"Example_"+sampleCnt+"_"+Version+".tif");

imOutMapPro=squeeze(max(imOut,[],4));
tifwrite(imOutMapPro, "Example_"+sampleCnt+"_"+Version+"_MaxPro.tif");
save("Example_"+sampleCnt+"_"+Version+"_linkMap.mat","linkMap",'-v7.3');