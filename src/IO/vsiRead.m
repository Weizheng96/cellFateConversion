function dat=vsiRead(datPath)
% datPath='Y:\cell fate conversion\Vglut3_Hey2_5dpf_regeneration_001.vsi';

data = bfopen(datPath);
info = data{1,1}{1,2};

[X,Y]=size(data{1,1}{1,1});

k1 = strfind(info,"Z?=");
k2 = strfind(info,"; C?=");
z_str=info(k1+3:k2-1);
k1 = strfind(z_str,"/");
Z=str2num(z_str(k1+1:end));

k1 = strfind(info,"C?=");
k2 = strfind(info,"; T?=");
c_str=info(k1+3:k2-1);
k1 = strfind(c_str,"/");
C=str2num(c_str(k1+1:end));

k1 = strfind(info,"T?=");
t_str=info(k1+3:end);
k1 = strfind(t_str,"/");
T=str2num(t_str(k1+1:end));

dat=zeros(X,Y,Z,T,C,'uint16');
for t=1:T
    t0=(t-1)*Z*C;
    for z=1:Z
        z0=(z-1)*C;
        for c=1:C
            dat(:,:,z,t,c)=data{1,1}{c+z0+t0,1};
        end
    end
end
end

