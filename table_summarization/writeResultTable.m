function writeResultTable(map_name,OTU_ID,Sample_ID,Data,tax)
fid=fopen([map_name '.txt'],'w');
fprintf(fid,'OTU ID');
for i=1:length(Sample_ID)
    fprintf(fid,'\t%s',Sample_ID{i});
end
if nargin==5
    fprintf(fid,'\ttaxonomy');
end
fprintf(fid,'\n');
for i=1:length(OTU_ID)
    fprintf(fid,'%s',OTU_ID{i});
    for j=1:length(Sample_ID)
        fprintf(fid,'\t%f',Data(i,j));
    end
    if nargin==5
        fprintf(fid,'\t%s',tax{i});
    end
    fprintf(fid,'\n');
end
end