function ZMap = synquant_2D_iter(input,minSZ,maxSZ,smoothingfactor,Mu,Sigma,detectionThreshold)
%%
imregion1 = double(input);
imregion1G = imgaussfilt(imregion1,smoothingfactor);
rmMap=false(size(imregion1));

iters1 = 1;
xxshift1 = zeros(2*iters1+1, 2*iters1+1);
yyshift1 = zeros(2*iters1+1, 2*iters1+1);
for i = -iters1:iters1
    for j = -iters1:iters1
        xxshift1(i+iters1+1,j+iters1+1) = i;
        yyshift1(i+iters1+1,j+iters1+1) = j;
    end
end
ZMap = zeros(size(imregion1G));

% SE = strel("disk",smoothingfactor);
% SE = strel("disk",1);

while true
    [lenx, leny] = size(imregion1G);
    ZMap_temp = zeros(size(imregion1G));

    for i = (ceil(max(imregion1G(:)))-1):-1:Mu
        mask = double(and(imregion1G > i,~rmMap));
%         mask = imopen(mask,SE);
        maskroi = bwlabeln(mask);
        maskroiIDx = label2idx(maskroi);
        lengthx = cellfun(@length, maskroiIDx);
        maskroiIDx(lengthx < 10) = [];
        for j = 1:length(maskroiIDx)
            idxtmp = maskroiIDx{j};
%             idxtmp(rmMap(idxtmp)==true)=[];
            N=length(idxtmp);
            if(N>minSZ&&N<maxSZ)
                idxtmpneiL1 = regionGrowxx(idxtmp,smoothingfactor, lenx,leny,xxshift1, yyshift1);
                idxtmpnei = setdiff(idxtmpneiL1, idxtmp);
                idxtmpnei(rmMap(idxtmpnei)==true)=[];
                if ~isempty(idxtmpnei)
                    signal = imregion1(idxtmp);
                    signalNei = imregion1(idxtmpnei);
                    [mutmp, sigmatmp] = ksegments_orderstatistics_fin(signal, signalNei);
                    meanDiff=mean(signal)-mean(signalNei);
                    zscore = (meanDiff - mutmp*Sigma)/(sigmatmp*Sigma);
                    if(zscore>max(ZMap_temp(idxtmp)))
                        ZMap_temp(idxtmp)=zscore;
                    end
                end
            end
        end
    end

    tempRmMap=ZMap_temp>detectionThreshold;
    if max(tempRmMap,[],'all')==true
%         tempRmMap=imdilate(tempRmMap,SE);
        rmMap=or(rmMap,tempRmMap);
        ZMap=ZMap+ZMap_temp;
    else
        break;
    end
end

end