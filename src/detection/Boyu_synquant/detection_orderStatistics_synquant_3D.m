
function [outputMask, imregion1G] = detection_orderStatistics_synquant_3D(input, zscoreThres, noiseSigma, smoothingfactor)
% disp(input)
imregion1 = double(input);
imregion1 = imregion1 - min(imregion1(:));
imregion1 = imregion1./max(imregion1(:)).*255;
imregion1G = imgaussfilt(imregion1,smoothingfactor);
svar=noiseSigma*255/double(max(input(:))-min(input(:))+1);

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
detectionRegion = zeros(size(imregion1G));
detectionZscoreRegion = zeros(size(imregion1G));
detectionRegionZthres = zeros(size(imregion1G));
% detectionRegionZcombined = zeros(size(imregion1G));
% localVariance = [];
% count = 1;
for i = (floor(max(imregion1G(:)))+1):-1:1
    mask = double(imregion1G > i);
    maskroi = bwlabeln(mask);
    maskroiIDx = label2idx(maskroi);
    lengthx = cellfun(@length, maskroiIDx);
    maskroiIDx(lengthx < 10) = [];
    for j = 1:length(maskroiIDx)
        %%%%%%%patch0
        idxtmp = maskroiIDx{j};
        idxtmpneiL1 = regionGrowxx_3D(idxtmp,1, lenx,leny,lenz,xxshift1, yyshift1);
        idxtmpneiL3 = regionGrowxx_3D(idxtmp,3, lenx,leny,lenz,xxshift1, yyshift1);
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
        idxtmpOldLabel = idxtmp(detectionRegion(idxtmp) == 1); 
        detectionZscoreRegion(idxtmpNewLabel) = zscorepatch0;
        detectionRegion(idxtmp) = 1;
        if(zscorepatch0 > zscoreThres && length(idxtmp) < 1000 )
            if isempty(idxtmpOldLabel) || zscorepatch0>max(detectionZscoreRegion(idxtmpOldLabel))
                detectionRegionZthres(idxtmp) = 1; 
            end
        end
    end
% 
end

outputMask = detectionRegionZthres;

implay(detectionZscoreRegion/100)



end