function eig_all = principalCurvature2d(imgIn, sigma, fmap)
% % Calculate 3D principle curvature on given foreground

%%%  get the hessian matrix
[Dxx, Dyy, Dxy, ~] = Hessian2D(imgIn,sigma);
if nargin < 3
    fmap = ones(size(imgIn)); % if we cal all the voxes
end

eig_all = zeros(size(imgIn));



s = regionprops(fmap, {'PixelIdxList'});
for i=1:numel(s)
    %disp(i);
    vox = s(i).PixelIdxList;
    xx = Dxx(vox); yy = Dyy(vox);
    xy = Dxy(vox);
    
    C = zeros(numel(s(i).PixelIdxList),2);
    for j=1:numel(s(i).PixelIdxList)
    % parfor j=1:numel(s(i).PixelIdxList)
        MM = [xx(j), xy(j);...
            xy(j), yy(j)];
        [~,Eval] = eig(MM);
        dEval = diag(Eval);
        [c,~] = sort(dEval,'descend');
        C(j,:) = c';
    end
    eig_all(vox) = C(:,1);
end

end