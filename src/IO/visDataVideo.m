function im=visDataVideo(dat_org,varargin)
%%

dat=dat_org;
if ~isempty(varargin)&&varargin{1}=="accurate"
    [X,Y,T,~]=size(dat_org);
    for ch=1:2
        roi3d_org=reshape(dat_org(:,:,:,ch),X,Y,1,T);
        roi3d=roi3d_org;
        V=connectivityBetweenCC_accurate4D(roi3d_org);
        IdxLst=mapColor(V);
        MAX=length(IdxLst);
        for i=1:MAX
            roi3d(roi3d_org==i)=IdxLst(i)+MAX;
        end  
        
        dat(:,:,:,ch)=squeeze(roi3d);
    end

end
%%
im=zeros([size(dat,[1 2]) 3 size(dat,3)]);
for t=1:size(dat,3)
    r=dat(:,:,t,2);
    r=mat2gray(r);
    g=dat(:,:,t,1);
    g=mat2gray(g);
    b=zeros(size(r));
    im(:,:,:,t)=cat(3,r,g,b);
end
end