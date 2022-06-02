%% iterative synquant
%% 

%% parameters
sampleCnt=2;
datafolderPath="E:\Project\ZhirongWang\data\3D\examples";
datPath=datafolderPath+"\dat_"+sampleCnt+".mat";
minSZ = 100;
maxSZ = 5000;
smoothingfactor=3;
detectionThreshold=2;
%% addpath 
srcPath = fileparts(which('main_V7.m')); 
addpath(genpath(srcPath));
%% read data
load(datPath);
dat=squeeze(max(double(dat_crop),[],3));
%% detection
[X,Y,T,~]=size(dat);
ZMap=zeros(size(dat));
MuLst=zeros(2,1);SigmaLst=zeros(2,1);

for channel=1:2
    [Mu,Sigma]=estimateNoiseMaxPro(dat(:,:,:,channel));
    MuLst(channel)=Mu;SigmaLst(channel)=Sigma;
    parfor t=1:T
        disp(channel+":"+t);
        ZMap(:,:,t,channel) = synquant_2D_iter(dat(:,:,t,channel),minSZ,maxSZ,smoothingfactor,Mu,Sigma,detectionThreshold);
    end
end

DtMap=ZMap>detectionThreshold;
%%
% imOut1=visDataVideo(dat);
% imOut2=visDataVideo(DtMap);
% imOut=cat(2,imOut1,imOut2);
% implay(imOut)
%% refine by PC
SE = strel("disk",1);
SE_large = strel("disk",smoothingfactor);

cellMap_PCrefine=zeros(size(dat));
seedMap=zeros(size(dat));

for channel=1:2
    parfor t=1:T
        disp(channel+":"+t);
        PCscoreMap = principalCurvature2d(dat(:,:,t,channel), smoothingfactor);
%         [gx,gy] = imgradient(imgaussian(dat(:,:,t,channel),1));
        [gx,gy] = imgradient(dat(:,:,t,channel));
        GradScoreMap=gx.^2+gy.^2;
        
        L=(DtMap(:,:,t,channel).*PCscoreMap)<0;
        L=bwlabeln(L);
        L=rmCC_bandPass(L,10,maxSz);
        
        seedMap(:,:,t,channel)=L;
        bg=~(DtMap(:,:,t,channel));
        bg=imerode(bg,SE_large);
        L(bg)=1; 
        L = splitROIbyWtrshd3D(ones(size(im)),L,GradScoreMap);
        
%         L=rmCC_bandPass(L,minSz,maxSz);
        cellMap_PCrefine(:,:,t,channel)=rmCC_bandPass(imopen(L,SE_large),minSz,maxSz);
    end
end
%%
% imOut1=visDataVideo(dat);
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
imOut1=visDataVideo(dat);
imOut2=visDataVideo(linkMap,"accurate");
imOut=cat(2,imOut1,imOut2);
cd(resultPath);
tifwrite(imOut, "Example_"+sampleCnt+"_0601.tif");
