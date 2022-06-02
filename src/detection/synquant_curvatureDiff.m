function diffIntMap = synquant_curvatureDiff(input,BgThr,minSZ,maxSZ,smoothingfactor)
%%
imregion1 = double(input);

pcXY3dMapFm = principalCurvature3d(imregion1, smoothingfactor);
imgIn = 1 - sqrt(max(0, pcXY3dMapFm/max(pcXY3dMapFm(:))));
imregion1G = imgIn*255;

FGmapStack = imregion1> BgThr;
FGmapStack = medfilt3(FGmapStack, [3,3,3]);
FGmapStack = imfill(FGmapStack,'holes');
seR = 3;
SE = false(seR*2+1, seR*2+1, seR*2+1);
SE(seR+1,seR+1,seR+1) = true;
temp = bwdist(SE);
SE = temp <= seR;
FGmapStack = imopen(FGmapStack,SE);
mask = imclose(FGmapStack,SE);

imregion1G(~mask)=0;


iters1 = 1; %11x11x5
xxshift1 = zeros(2*iters1+1, 2*iters1+1);
yyshift1 = zeros(2*iters1+1, 2*iters1+1);
for i = -iters1:iters1
    for j = -iters1:iters1
        xxshift1(i+iters1+1,j+iters1+1) = i;
        yyshift1(i+iters1+1,j+iters1+1) = j;
    end
end

[lenx, leny, lenz] = size(imregion1G);
diffIntMap = zeros(size(imregion1G));

for i = (ceil(max(imregion1G(:)))-1):-1:1
    mask = double(imregion1G > i);
    maskroi = bwlabeln(mask);
    maskroiIDx = label2idx(maskroi);
    lengthx = cellfun(@length, maskroiIDx);
    maskroiIDx(lengthx < 10) = [];
    for j = 1:length(maskroiIDx)
        %%%%%%%patch0
        idxtmp = maskroiIDx{j};
        N=length(idxtmp);
        if(N>minSZ&&N<maxSZ)
            idxtmpneiL1 = regionGrowxx_3D(idxtmp,smoothingfactor, lenx,leny,lenz,xxshift1, yyshift1);
            idxtmpnei = setdiff(idxtmpneiL1, idxtmp);
            signal = imregion1(idxtmp);
            signalNei = imregion1(idxtmpnei);
            diffInt=mean(signal)-mean(signalNei);
            if(diffInt>max(diffIntMap(idxtmp)))
                diffIntMap(idxtmp)=diffInt;
            end
%             diffIntMap(idxtmp)=max(diffInt,diffIntMap(idxtmp));
        end
    end
end

diffIntMap=diffIntMap*max(pcXY3dMapFm(:));

end