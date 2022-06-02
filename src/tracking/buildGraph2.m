function [trackG,para,DetectionRegion]=buildGraph2(ID_loc2glo,ID_glo2loc,detection_corrected)
%% get valid range
% validRegion=max(detection_org>0,[],4);
% [I1_org,I2_org,I3_org]=ind2sub(size(validRegion),find(validRegion));
% min_max_xyz=[  min(I1_org) min(I2_org) min(I3_org);...
%                max(I1_org) max(I2_org) max(I3_org);
%                size(validRegion)];
% detection_corrected=detection_org(  min_max_xyz(1,1):min_max_xyz(2,1),...
%                                     min_max_xyz(1,2):min_max_xyz(2,2),...
%                                     min_max_xyz(1,3):min_max_xyz(2,3),:);
%%
[X,Y,Z,T]=size(detection_corrected);
N0=length(ID_glo2loc);
MINORCOST=10^-2;
MAXCOST=100;
%% get REGION of each detection
DetectionRegion=cell(N0,1);
tic
for i=1:N0
    disp(i);
    IDi=ID_glo2loc(i,:);ti=IDi(1);idi=IDi(2);
    DetectionRegion{i}=find(detection_corrected(:,:,:,ti)==idi);
end
toc
%% Calculate cost between two detection
tic
CostMapRaw=Inf(N0,N0);
parfor i=1:N0
    disp(i);
    ti=ID_glo2loc(i,1);
    Di=false(X,Y,Z);Di(DetectionRegion{i})=true;
    Dti=bwdist(Di);
    % distance to other detection
    for j=1:N0
        tj=ID_glo2loc(j,1);
        if ti==(tj-1)||ti==(tj+1)
            CostMapRaw(i,j)=mean(Dti(DetectionRegion{j}));
        end
    end
end
toc
%%
% cd("E:\Project\embryo\data\matFile\002_MidRes\DT_res");
% save("CostMapRaw_v2.5.mat","CostMapRaw","-v7.3");
% cd("E:\Project\embryo\data\matFile\002_MidRes\DT_res");
% load("CostMapRaw.mat");
%% get cost
costMap=Inf(N0,N0);
for i=1:N0
    for j=i+1:N0
        costMap(i,j)=max(CostMapRaw(i,j),CostMapRaw(j,i));
    end
end

%% setting of graph
para.nCellRep=2*N0+2;
para.source=2*N0+1;
para.sink=2*N0+2;

%% between detection
linkId=find(costMap<MAXCOST);
[Edgefrom,Edgeto]=ind2sub([N0,N0],linkId);
arcTails=Edgefrom*2;
arcHeads=Edgeto*2-1;
arcCosts=costMap(linkId);
%% within detection
subTails=(1:N0)'*2-1;
subHeads=(1:N0)'*2;
subCost=-ones(N0,1)*MAXCOST;

arcTails=[arcTails;subTails];
arcHeads=[arcHeads;subHeads];
arcCosts=[arcCosts;subCost];
%% from source
subTails=ones(N0,1)*para.source;
subHeads=(1:N0)'*2-1;
subCost=ones(N0,1)*(MAXCOST/2-MINORCOST);

arcTails=[arcTails;subTails];
arcHeads=[arcHeads;subHeads];
arcCosts=[arcCosts;subCost];
%% to sink
subTails=(1:N0)'*2;
subHeads=ones(N0,1)*para.sink;
subCost=ones(N0,1)*(MAXCOST/2-MINORCOST);

arcTails=[arcTails;subTails];
arcHeads=[arcHeads;subHeads];
arcCosts=[arcCosts;subCost];

%% build graph
arcCosts=round(arcCosts./MINORCOST);
trackG = digraph(arcTails,arcHeads,arcCosts);

end