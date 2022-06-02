function [roiMap, pcXY3dMapFm] = inFmSegment3D(img_raw, PCsigma, minSz, maxSz)
imgFm=mat2gray(img_raw);
%% background intensity
img = max(imgFm,[],3);
contrastVec = zeros(254,1);
for thr = 1:254
    roiMap = img > thr/255;
    roiOuterEdgeMap = imdilate(roiMap,strel('disk',1)) & ~roiMap;
    contrastVec(thr) = mean(img(roiMap)) - mean(img(roiOuterEdgeMap));
end
windowSz = 3;
b = (1/windowSz)*ones(1,windowSz);
fltdContrastVec = filter(b,1,contrastVec);
slctThr = find((fltdContrastVec >= [0;fltdContrastVec(1:end-1)]) &...
    (fltdContrastVec >= [fltdContrastVec(2:end);0]), 1, 'first');
%% synquant
q.minIntensity =slctThr;
[~, roiMap, ~] = Synquant4Embryo_Paramater(round(imgFm*255), q, minSz, maxSz);

%%
pcXY3dMapFm = principalCurvature3d(imgFm, PCsigma);

end





