function [idx12,idx21]=AlignID(ID1,ID2)
% 2->1
n1=length(ID1);
n2=length(ID2);
idx12=zeros(n1,1);
idx21=zeros(n2,1);
for i=1:n1
    s1=strtrim(ID1{i});
    for j=1:n2
        s2=strtrim(ID2{j});
        if strcmpi(s1,s2)
            idx12(i)=j;
            break;
        end
    end
end
for i=1:n2
    s2=strtrim(ID2{i});
    for j=1:n1
        s1=strtrim(ID1{j});
        if strcmpi(s1,s2)
            idx21(i)=j;
            break;
        end
    end
end
end