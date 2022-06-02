
function diffIntMap = synquant_intensityDiff(input,intensityThres,minSZ,maxSZ,smoothingfactor)
%%
imregion1 = double(input);
imregion1G = imgaussfilt(imregion1,smoothingfactor);

% implay(mat2gray(imregion1G))
% implay(mat2gray(pcXY3dMapFm))


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

for i = (ceil(max(imregion1G(:)))-1):-1:intensityThres
    mask = double(imregion1G > i);
    maskroi = bwlabeln(mask);
    maskroiIDx = label2idx(maskroi);
    lengthx = cellfun(@length, maskroiIDx);
    maskroiIDx(lengthx < 10) = [];
    for j = 1:length(maskroiIDx)
        %%%%%%%patch0
        idxtmp = maskroiIDx{j};
        N=length(idxtmp);
        if(N<maxSZ&&N>minSZ)
            idxtmpneiL1 = regionGrowxx_3D(idxtmp,smoothingfactor, lenx,leny,lenz,xxshift1, yyshift1);
            idxtmpnei = setdiff(idxtmpneiL1, idxtmp);
            signal = imregion1(idxtmp);
            signalNei = imregion1(idxtmpnei);
            diffInt=mean(signal)-mean(signalNei);
%             if(diffInt>max(diffIntMap(idxtmp)))
%                 diffIntMap(idxtmp)=diffInt;
%             end
            diffIntMap(idxtmp)=max(diffInt,diffIntMap(idxtmp));
        end
    end
end

% pcXY3dMapFm = principalCurvature3d(mat2gray(imregion1), smoothingfactor);
% PCmap=1-mat2gray(min(max(pcXY3dMapFm,0),5));
% diffIntMap =diffIntMap .*PCmap;

end