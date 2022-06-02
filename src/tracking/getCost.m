function costMap=getCost(detectionArea,interArea)
%% IOU
N0=length(detectionArea);
unionArea=zeros(N0);

for i=1:N0
    for j=i+1:N0
        unionArea(i,j)=detectionArea(i)+detectionArea(j)-interArea(i,j);
    end
end

costMap=interArea./unionArea;



end

