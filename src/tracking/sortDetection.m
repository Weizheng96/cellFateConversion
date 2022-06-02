function [ID_loc2glo,ID_glo2loc,DetectionNumLst]=sortDetection(detection_corrected)

T=size(detection_corrected,4);
k=0;
for i=1:T
    CCNum=max(detection_corrected(:,:,:,i),[],'all');
    for j=1:CCNum
        k=k+1;
        ID_loc2glo(i,j)=k;
        ID_glo2loc(k,:)=[i j];
    end
    DetectionNumLst(i)=CCNum;
end

ID_glo2loc=double(ID_glo2loc);

end