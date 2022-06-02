
%% based on java synQuant
%% too slow

%% parameters
datPath="E:\Project\ZhirongWang\data\3D\examples\dat_1.mat";
%% addpath
% srcPath = mfilename('fullpath'); 
srcPath = fileparts(which('main.m')); 
addpath(genpath(srcPath));
synQuantPath = [srcPath '\detection\Yinxue_segment\'];
Pij = fullfile(synQuantPath, 'src_synquant/ij-1.52i.jar');
javaaddpath(Pij);
p1 = fullfile(synQuantPath,'src_synquant/commons-math3-3.6.1.jar');
javaaddpath(p1);%
p0 = fullfile(synQuantPath, 'src_synquant/SynQuantVid_v1.2.4.jar');
javaaddpath(p0);%
%% read data
load(datPath);
dat=mat2gray(double(dat_crop));
visData(dat,1);
visDataMaxPro(dat)
%% detection
DtMap=zeros(size(dat));
PCsigma = 3;
minSz = 50;
maxSz = 10000;
[X,Y,Z,T,~]=size(dat);
for t=1:20
    disp(t+"/"+T)
    for channel=1:2
    [DtMap(:,:,:,t,channel),~] = inFmSegment3D(dat(:,:,:,t,channel), PCsigma, minSz, maxSz);
    end
end

visDataMaxPro(DtMap)