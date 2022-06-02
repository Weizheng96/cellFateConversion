%% NO synquant
%% 

%% parameters
sampleCnt=3;
datafolderPath="E:\Project\ZhirongWang\data\3D\examples";
datPath=datafolderPath+"\dat_"+sampleCnt+".mat";
minSz = 50;
maxSz = 10000;
smoothingfactor=[3 3 1];
detectionThreshold=2;
%% addpath 
srcPath = fileparts(which('main_V6.m')); 
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
smoothingfactor_2D=smoothingfactor(1);
SE = strel("disk",smoothingfactor_2D);
SE_large = strel("disk",smoothingfactor_2D);


dat2D=squeeze(max(dat,[],3));
cellMap_PCrefine=zeros(size(dat2D));
seedMap=zeros(size(dat2D));

for channel=1:2
    parfor t=1:T
        disp(channel+":"+t);
        L=PC_seed(:,:,:,t,channel);
%         L = imclose(L,SE);
%         L = imopen(L,SE);
        L=max(bwlabeln(L),[],3);
%         L=rmCC_bandPass(L,minSz,maxSz);
        seedMap(:,:,t,channel)=L;
        bg=~(max(DtMap(:,:,:,t,channel),[],3));
        bg=imerode(bg,SE_large);
        L(bg)=max(L,[],'all')+1;
        scoreMap = principalCurvature2d(dat2D(:,:,t,channel),smoothingfactor_2D);
        
        L = splitROIbyWtrshd3D(ones(size(im)),L,scoreMap);
        cellMap_PCrefine(:,:,t,channel)=rmCC_bandPass(L,minSz,maxSz);
    end
end
%% display detection
% imOut1=visDataVideo(dat2D);
% imOut2=visDataVideo(cellMap_PCrefine);
% imOut=cat(2,imOut1,imOut2);
% implay(imOut) 

%% link
linkMap=zeros(X,Y,1,T,2);
for channel=1:2
    detection_refined=reshape(cellMap_PCrefine(:,:,:,channel),X,Y,1,T);
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

linkMap=squeeze(linkMap);

%%
imOut1=visDataVideo(dat2D);
imOut2=visDataVideo(linkMap,"accurate");
imOut=cat(2,imOut1,imOut2);
cd(resultPath);
tifwrite(imOut, "Example_"+sampleCnt+"_0531.tif");