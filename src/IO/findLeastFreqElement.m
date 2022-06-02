function minmode=findLeastFreqElement(V)

uv = unique(V); 
n = histcounts(V,uv);
[~,i] = min(n) ;
minmode = uv(i);

end