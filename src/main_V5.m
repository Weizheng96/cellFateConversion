
%% global threshold
%% 

%% parameters
sampleCnt=3;
datafolderPath="E:\Project\ZhirongWang\data\3D\examples";
datPath=datafolderPath+"\dat_"+sampleCnt+".mat";
minSz = 50;
maxSz = 100000;
smoothingfactor=[3 3 1];
detectionThreshold=3;
%% addpath 
srcPath = fileparts(which('main_V5.m')); 
addpath(genpath(srcPath));
%% read data
load(datPath);
dat=double(dat_crop);

%% detection
[X,Y,Z,T,~]=size(dat);
ZMap=zeros(size(dat));
MuLst=zeros(2,1);SigmaLst=zeros(2,1);

datSmo=zeros(size(dat));
datPC=zeros(size(dat));
for channel=1:2
    [Mu,Sigma]=estimateNoise(dat(:,:,:,:,channel));
    MuLst(channel)=Mu;SigmaLst(channel)=Sigma;
    parfor t=1:T
        disp(channel+":"+t);
        datSmo(:,:,:,t,channel)=imgaussfilt3(dat(:,:,:,t,channel),smoothingfactor);
        datPC(:,:,:,t,channel) = principalCurvature3d(dat(:,:,:,t,channel),smoothingfactor);
    end
    ZMap(:,:,:,:,channel)=(datSmo(:,:,:,:,channel)-Mu)/Sigma;
end
DtMap=ZMap>detectionThreshold;
PC_seed=(datPC.*DtMap)<0;

%% refine by PC
cellMap_PCrefine=zeros(size(dat));
seedMap=zeros(size(dat));
SE = strel("disk",smoothingfactor(1));
for channel=1:2
    parfor t=1:T
        disp(channel+":"+t);
        L=bwlabeln(PC_seed(:,:,:,t,channel));
        L = imclose(L,SE);
        L = imopen(L,SE);
        seedMap(:,:,:,t,channel)=rmCC_bandPass(L,minSz,maxSz);
        
    end
end
%% display detection
% imOut1=visDataMaxPro(dat);
% imOut2=visDataMaxPro(seedMap);
% imOut=cat(2,imOut1,imOut2);
% implay(imOut) 
%% link
linkMap=zeros(size(dat));
for channel=1:2
    detection_refined=seedMap(:,:,:,:,channel);
    [ID_loc2glo,ID_glo2loc,DetectionNumLst]=sortDetection(detection_refined);
    [trackG,para,DetectionRegion,min_max_xyz]=buildGraph2(ID_loc2glo,ID_glo2loc,detection_refined);
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
            idxLoc=idTrans(DetectionRegion{traceTemp(i)},min_max_xyz);
            idxGlo=idxLoc+SZframe*(IDloc(1)-1);
            detection_linked(idxGlo)=cnt;
        end
    end
    linkMap(:,:,:,:,channel)=detection_linked;
end


%% display linkage
for channel=1:2
    outIm = imdisplayWithMapColor4D(dat(:,:,:,:,channel), linkMap(:,:,:,:,channel));
    outIm_maxPro=squeeze(max(outIm,[],4));
    
    im=squeeze(max(dat(:,:,:,:,channel),[],3));
    [X,Y,T]=size(im);
    im_vis0=reshape(uint8(mat2gray(im)*255),[X Y 1 T]);
    rawIm=cat(3,im_vis0,im_vis0,im_vis0);
    
    im_Vis=cat(2,rawIm,outIm_maxPro);
    cd(resultPath);
    tifwrite(im_Vis, "Example_"+sampleCnt+"_channel_"+channel+"_0527.tif");
end
%%
% tifwrite(imOut, 'DT_1');