function [BgThre,NoiseLv]=foreIntensityThreshold(img,p)

if ~exist('p','var')
    p=0.01;
end

MAX=max(img(:));
MIN=min(img(:));
edges=MIN:MAX;
N = histcounts(img,edges);
[M,I]=max(N);
I_low=find(N>p*M,1);
NoiseLv=I-I_low;
I_high=I*2-I_low;
BgThre=edges(I_high);
end