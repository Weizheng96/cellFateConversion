
function [outputMask, imregion1G] = detection_orderStatistics_synquant(input, zthresca3, svar, smoothingfactor)
% disp(input)
imregion1 = double(input);
imregion1 = imregion1 - min(imregion1(:));
imregion1 = imregion1./max(imregion1(:)).*255;
imregion1G = imgaussfilt(imregion1,smoothingfactor);

localmean5 = imboxfilt(imregion1,[5,5]);
localmean3 = imboxfilt(imregion1,[3,3]);    
imregion2 = imregion1(3:end-2, 3:end-2);
localmean2 = 25.*localmean5(3:end-2, 3:end-2) - 9.*localmean3(3:end-2, 3:end-2);
localmean2 = localmean2./(25-9);
[h,w] = size(imregion1);
iters1 = 1; %11x11x5
xxshift1 = zeros(2*iters1+1, 2*iters1+1);
yyshift1 = zeros(2*iters1+1, 2*iters1+1);
for i = -iters1:iters1
    for j = -iters1:iters1
        xxshift1(i+iters1+1,j+iters1+1) = i;
        yyshift1(i+iters1+1,j+iters1+1) = j;
    end
end

zscoreThres = zthresca3;
[lenx, leny] = size(imregion1G);
detectionRegion = zeros(size(imregion1G));
detectionZscoreRegion = zeros(size(imregion1G));
detectionRegionZthres = zeros(size(imregion1G));
detectionRegionZcombined = zeros(size(imregion1G));
% localVariance = [];
% count = 1;
for i = (floor(max(imregion1G(:)))+1):-1:1
    mask = double(imregion1G > i);
    maskroi = bwlabel(mask);
    maskroiIDx = label2idx(maskroi);
    lengthx = cellfun(@length, maskroiIDx);
    maskroiIDx(lengthx < 10) = [];
    for j = 1:length(maskroiIDx)
        %%%%%%%patch0
        idxtmp = maskroiIDx{j};
        idxtmpneiL1 = regionGrowxx(idxtmp,1, lenx,leny,xxshift1, yyshift1);
        idxtmpneiL3 = regionGrowxx(idxtmp,3, lenx,leny,xxshift1, yyshift1);
        idxtmpnei = setdiff(idxtmpneiL1, idxtmp);
        idxtmpnei3 = setdiff(idxtmpneiL3, idxtmp);
        signal = imregion1(idxtmp);
        signalNei = imregion1(idxtmpnei);
        signalNei3 = imregion1(idxtmpnei3);
        if(~isempty(signal) && ~isempty(signalNei))
            [mutmp, sigmatmp] = ksegments_orderstatistics_fin(signal, signalNei);
            meanDiff = mean(signal) - mean(signalNei3);
            zscorepatch0 = (meanDiff - mutmp.*svar)./(svar.*sigmatmp);
        else
            zscorepatch0 = nan;
        end
        %%%%%pick the largest from the two
        idxtmpNewLabel = idxtmp(detectionRegion(idxtmp) == 0);  
        detectionZscoreRegion(idxtmpNewLabel) = zscorepatch0;
        detectionRegion(idxtmp) = 1;
        if(zscorepatch0 > zscoreThres && length(idxtmp) < 100 )
            detectionRegionZcombined(idxtmp) = 1;
            if(sum(detectionRegionZthres(idxtmp)) == 0)
                detectionRegionZthres(idxtmp) = 1; 
            end
        end
    end
% 
end

synIdAllfin = detectionRegionZcombined;
synId1 = detectionRegionZthres;

outputMask = synId1;
synId1Label = bwlabel(detectionRegionZthres);
synIdAllxIDX = label2idx(bwlabel(detectionRegionZcombined));
for j = 1:length(synIdAllxIDX)
    idxAll = synIdAllxIDX{j};
    labelAll = unique(synId1Label(idxAll));
    if(sum(labelAll > 0) >=2)
        [idxAll, idyAll] = ind2sub([h,w], idxAll);
        roiWS = synId1(min(idxAll):max(idxAll), min(idyAll):max(idyAll));
        D = bwdist(roiWS);
        DL = watershed(D);
        bgm = double(DL == 0);
        roiWS2 = synIdAllfin(min(idxAll):max(idxAll), min(idyAll):max(idyAll));
        roiWS2 = roiWS2.*(1 - bgm);
        synIdAllfin(min(idxAll):max(idxAll), min(idyAll):max(idyAll)) = roiWS2;
    end
end

synIdAllfinROI = bwlabel(synIdAllfin);
synIdAllfinROIIDX = label2idx(synIdAllfin);
lengthsynIdAllfin = cellfun(@length,synIdAllfinROIIDX);
synIdAllfinROIIDX(lengthsynIdAllfin < 10) = [];
newSynIdAllfin = zeros(h,w);
for i = 1:length(synIdAllfinROIIDX)
    newSynIdAllfin(synIdAllfinROIIDX{i}) = 1;
    
end


end