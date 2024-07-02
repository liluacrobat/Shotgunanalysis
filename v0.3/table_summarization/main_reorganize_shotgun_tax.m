function main_reorganize_shotgun_tax
clc;clear;close all
fname = 'Assembly_pip/Combined_ready_table.txt';
tbl = readtable(fname,'delimiter','\t','ReadVariableNames',1);
raw = tbl.taxonomy;
L = zeros(size(raw));
Re = cell(size(raw));
ReOTU = cell(size(raw));
id = tbl.OTUID;
for i=1:length(id)
    OTU{i,1} = num2str(id(i));
end
fid = fopen('reformated_tax.txt','w');
for i=1:length(raw)
    tmp = raw{i};
    if strcmpi(tmp,'Archaea')
        tmp = 'Archaea;Archaea';
    end
    if strcmpi(tmp,'Bacteria')
        tmp = 'Bacteria;Bacteria';
    end
    s = strsplit(tmp,';');
    pp = '';
    L(i) = length(s);
    for k=1:length(s)
        [~,tax,flag] = rmHead(s{k});
        if flag==0
            if isempty(strrep(tax,'_unclassified',''))
                if ~contains(pp,'_unclassified')
                    ps=strcat(pp,'_unclassified');
                else
                    ps = pp;
                end
                s{k} = ps;
            else
                pp = s{k};
            end
            
        end
    end
    ks = fun_recombine(s);
    Re{i,1} = ks;
end
NT = max(L);
for i=1:length(Re)
    ss = strsplit(Re{i},';');
    if L(i)<NT
        pp=ss{end};
        if ~contains(pp,'_unclassified')
            ps=strcat(pp,'_unclassified');
        else
            ps = pp;
        end
        for j=L(i)+1:NT
            ss{end+1} = ps;
        end
    end
    ks = fun_recombine(ss);
    Re{i,1} = ks;
    ReOTU{i,1} = Re{i,1};
end
L2 = zeros(size(L));
for i=1:length(Re)
    tmp = Re{i};
    s = strsplit(tmp,';');
    L2(i,1) = length(s);
end
fprintf(fid,'original\tnew\tOTU\n');
for i=1:length(raw)
    fprintf(fid,'%s\t%s\t%s\n',raw{i},Re{i},ReOTU{i});
end
counts = table2array(tbl(:,2:end-1));
fid1 = fopen(fname,'r');
line = fgetl(fid1);
fid2 = fopen(strcat(fname,'.reformated.txt'),'w');
fprintf(fid2,'%s\n',line);
for i=1:length(raw)
    fprintf(fid2,'%s',OTU{i});
    for j=1:size(counts,2)
        fprintf(fid2,'\t%f',counts(i,j));
    end
    fprintf(fid2,'\t%s',ReOTU{i});
    fprintf(fid2,'\n');
end
end
function [head,tax,flag] = rmHead(x)
s = strsplit(x,'__');
flag = 0;
head = '';
tax = '';
if length(s)~=2
    flag=1;
    %     keyboard;
else
    head = s{1};
    tax = s{2};
end

end
function ks = fun_recombine(s)
ks = s{1};
for p=2:length(s)
    ks=strcat(ks,';',strtrim(s{p}));
end

end
