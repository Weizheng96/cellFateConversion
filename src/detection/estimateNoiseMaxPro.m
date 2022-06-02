function [Mu,Sigma]=estimateNoiseMaxPro(img)
img=img(:);
MAX=max(img);
MIN=min(img);
edges=MIN:MAX;
N = histcounts(img,edges);
[N_max,I]=max(N);
p = normpdf(1);
I_up=find(N>(N_max*p),1,'last');
Mu=edges(I);
Sigma=edges(I_up+1)-edges(I);
end