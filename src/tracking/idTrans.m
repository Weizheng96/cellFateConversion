function idxLoc=idTrans(ID_org,min_max_xyz)

SZ_s=min_max_xyz(2,:)-min_max_xyz(1,:)+1;
SZ_b=min_max_xyz(3,:);
[x,y,z]=ind2sub(SZ_s,ID_org);
xb=x+min_max_xyz(1,1)-1;yb=y+min_max_xyz(1,2)-1;zb=z+min_max_xyz(1,3)-1;
idxLoc=sub2ind(SZ_b,xb,yb,zb);

end