function IdxLst=mapColor(connectTable)

% colorNum=max(sum(connectTable));
colorNum=4;
fullSet=1:colorNum;

N=size(connectTable,1);

IdxLst=randi([1 colorNum],1,N);
flag=true;
cnt=0;
while flag
    flag=false;
    cnt=cnt+1;
    for i=1:N
        thisCor=IdxLst(i);
        conIdx=connectTable(i,:);
        conCor=IdxLst(conIdx);

        if length(find(conCor==thisCor))>1
            r = setxor(fullSet,unique(conCor));
            if ~isempty(r)
                IdxLst(i)=r(1);
            else
                conCor2=IdxLst(conIdx);
                IdxLst(i)=findLeastFreqElement(conCor2);
                flag=true;
            end
        end
    end
    if cnt>100
        flag=false;
    end
end

end