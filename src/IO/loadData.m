%% parameters
datPath='Y:\cell fate conversion\Vglut3_Hey2_5dpf_regeneration_001.vsi';
%% read data
dat=vsiRead(datPath);
%% save mat
cd("Z:\ZhirongWang\Vglut3_Hey2_5dpf_regeneration_001");
save("dat","dat","-v7.3")