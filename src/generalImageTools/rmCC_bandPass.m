function newMap=rmCC_bandPass(Map,minSZ,maxSZ)

newMap=zeros(size(Map));
Lst=unique(Map(:));
Lst(Lst==0)=[];
k=0;
if ~isempty(Lst)
    
    for i=Lst'
        temp_lst=find(Map==i);
    %     fprintf(i+":\t"+length(temp_lst));
        if length(temp_lst)>=minSZ && length(temp_lst)<=maxSZ
    %         fprintf("\t Y\n");
            k=k+1;
            newMap(temp_lst)=k;
        else
    %         fprintf("\t N\n");
        end
    end
    
else
    
    newMap=Map;
    
end

end