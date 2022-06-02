function im=visDataVideo3D(dat_org,varargin)
%%

dat=dat_org;
if ~isempty(varargin)&&(varargin{1}=="accurate"||varargin{1}=="colorful")
    for ch=1:2
        roi3d_org=dat_org(:,:,:,:,ch);
        roi3d=roi3d_org;
        V=connectivityBetweenCC_accurate4D(roi3d_org);
        IdxLst=mapColor(V);
        MAX=length(IdxLst);
        for i=1:MAX
            roi3d(roi3d_org==i)=IdxLst(i)+MAX;
        end  
        
        dat(:,:,:,:,ch)=squeeze(roi3d);
    end

end
%%

if ~isempty(varargin)&&(varargin{1}=="colorful")
    [X,Y,Z,T,~]=size(dat);
    outIm = zeros(X,Y,3,Z,T,2);
    for ch=1:2
        nParticle = double(max(dat(:,:,:,:,ch),[],'all'));
        if ch==1
            cmap = winter(nParticle);
        else
            cmap = autumn(nParticle);
        end
        cCnt = randperm(nParticle);

        roi3d=reshape(dat(:,:,:,:,ch),[X,Y,1,Z,T]);

        r = zeros(size(roi3d));
        g = zeros(size(roi3d));
        b = zeros(size(roi3d));
        N=int64(X)*int64(Y)*int64(Z)*int64(T);
        for i=1:N
            j=roi3d(i);
            if j~=0
                r(i) = cmap(cCnt(j),1);
                g(i) = cmap(cCnt(j),2);
                b(i) = cmap(cCnt(j),3);
            end
        end
        outIm(:,:,1,:,:,ch) = r;
        outIm(:,:,2,:,:,ch) = g;
        outIm(:,:,3,:,:,ch) = b;
    end
    im=max(outIm,[],6);
else
    
    
    [X,Y,Z,T,~]=size(dat);
    % roi3d_org=reshape(dat_org(:,:,:,ch),X,Y,1,T);
    im=zeros([size(dat,[1 2]) 3 size(dat,[3 4])]);
    for t=1:T
        r=dat(:,:,:,t,2);
        r=mat2gray(r);
        r=reshape(r,X,Y,1,Z);
        g=dat(:,:,:,t,1);
        g=mat2gray(g);
        g=reshape(g,X,Y,1,Z);
        b=zeros(size(r));
        im(:,:,:,:,t)=cat(3,r,g,b);
    end

end
end