function R = readK2table(filename,s_flag)
if nargin<2
    s_flag = 0;
end
f_id=fopen(filename,'r');
n=0;
head = 1;
sample = [];
s_id2 = [];
nl = 0;
while ~feof(f_id)
    n=n+1;
    display(n);
    line=fgetl(f_id);
    S=strsplit(line,'\t');
    if isempty(S{end})
        S = S(1:end-1);
    end
    if head==1
        if startsWith(line,'#')
            if length(S)>1
                if length(S)>2
                    head = 0;
                    header = S;
                else
                    s_id2{end+1} = [S{1}(3:end) '_lvl'];
                    report = S{2};
                    report_full = strsplit(report,'/');
                    report_id = strsplit(report_full{end},'.report');
                    if s_flag==1
                        sample{end+1} = removeTail(report_id{1});
                    else
                        sample{end+1} = report_id{1};
                    end
                end
            end
        end
    else
        nl=nl+1;
    end
end
f_id=fopen(filename,'r');
head = 1;
tab = zeros(nl,length(header)-3);
taxid = cell(nl,1);
type = zeros(nl,1);
taxname = cell(nl,1);
calflag = zeros(1,8);
si = ones(1,8)*100;
ancestor = cell(1,8);
nl = 0;
while ~feof(f_id)
    line=fgetl(f_id);
    S=strsplit(line,'\t');
    if isempty(S{end})
        S = S(1:end-1);
    end
    if head==1
        if startsWith(line,'#')
            if length(S)>1
                if length(S)>2
                    head = 0;
                end
            end
        end
    else
        nl = nl+1;
        if mod(nl,100)==0
            display(nl);
        end
        L = length(S);
        for i=1:L-3
            tab(nl,i) = str2double(S{i});
        end
        taxid{nl} = S{L-1};
        seq = typeNorm(S{L-2});
        type(nl) = seq;
        tmp = S{L};
        for k=1:length(tmp)
            if strcmp(tmp(k),' ')~=1
                sn = k-1;
                break;
            end
        end
        
        S{L} = strtrim(S{L});
        if seq<0
            taxname{nl} = 'NA';
            ancestor = cell(1,8);
            calflag = zeros(1,8);
            si = ones(1,8)*100;
        else
            if seq==0
                taxname{nl} = 'unclassified';
                ancestor = cell(1,8);
                calflag = zeros(1,8);
                si = ones(1,8)*100;
            else
                rank = ceil(seq/2);
                prim = mod(seq,2);
                if rank==1
                    if prim==1
                        ancestor{rank} = S{L};
                        taxname{nl} = S{L};
                        si(rank) = sn;
                        for k=rank+1:8
                            ancestor{k} = strcat(S{L},'_unclassified');
                        end
                        
                        calflag(rank) = 1;
                        calflag(rank+1:8) = 0;
                        switch S{L}
                            case 'Bacteria'
                                ancestor{2} = 'Bacteria';
                                calflag(2) = 1;
                                si(2) = sn;
                            case 'Archaea'
                                ancestor{2} = 'Archaea';
                                calflag(2) = 1;
                                si(2) = sn;
                        end
                    else
                        
                        if strcmp(ancestor{rank},'Bacteria')==1 || strcmp(ancestor{rank},'Archaea')==1
                            taxname{nl} = strcat(ancestor{rank},';',ancestor{rank},';',ancestor{rank},'_unclassified');
                            for k=rank+2:8
                                ancestor{k} = strcat(ancestor{rank},'_unclassified');
                            end
                            calflag(rank+2:8) = 0;
                            si(rank+2:8) = 100;
                        else
                            taxname{nl} = strcat(ancestor{rank},';',ancestor{rank},'_unclassified');
                            for k=rank+1:8
                                ancestor{k} = strcat(ancestor{rank},'_unclassified');
                            end
                            calflag(rank+1:8) = 0;
                            si(rank+1:8) = 100;
                        end
                    end
                else
                    if calflag(1)==1
                        fulltax = ancestor{1};
                        tmp = ancestor{1};
                        for k=2:rank-1
                            if si(k)<sn
                                fulltax = strcat(fulltax,';',ancestor{k});
                                tmp = ancestor{k};
                            else
                                for kp=k:rank-1
                                    fulltax = strcat(fulltax,';',tmp,'_unclassified');
                                    ancestor{kp} = strcat(tmp,'_unclassified');
                                end
                                si(k:rank-1) = sn;
                                calflag(k:rank-1) = 0;
                                break
                            end
                        end
                        if si(rank)>sn
                            ancestor{rank} = strcat(tmp,'_unclassified');
                            si(rank) = sn;
                            calflag(rank) = 0;
                            for k=rank+1:8
                                 ancestor{k} = strcat(tmp,'_unclassified');
                            end
                            calflag(rank+1:8) = 0;
                            si(rank+1:8) = 100;
                        end
                        if prim==1
                            taxname{nl} = strcat(fulltax,';',S{L});
                            ancestor{rank} = S{L};
                            for k=rank+1:8
                                ancestor{k} = strcat(S{L},'_unclassified');
                            end
                            si(rank) = sn;
                            si(rank+1:8) = 100;
                            calflag(rank) = 1;
                            calflag(rank+1:8) = 0;
                        else
                            if rank<8
                                if calflag(rank) == 0
                                    taxname{nl} = strcat(fulltax,';',ancestor{rank},';',ancestor{rank});
                                    for k=rank+1:8
                                        ancestor{k} = ancestor{rank};
                                    end
                                    calflag(rank+1:8) = 0;
                                    si(rank+1:8) = 100;
                                else
                                    taxname{nl} = strcat(fulltax,';',ancestor{rank},';',ancestor{rank},'_unclassified');
                                    for k=rank+1:8
                                        ancestor{k} = strcat(ancestor{rank},'_unclassified');
                                    end
                                    calflag(rank+1:8) = 0;
                                    si(rank+1:8) = 100;
                                end
                            else
                                taxname{nl} = strcat(fulltax,';',ancestor{rank});
                            end
                        end
                    else
                        type(nl) = -1;
                        taxname{nl} = 'NA';
                        ancestor = cell(1,8);
                        calflag = zeros(1,8);
                        si = ones(1,8)*100;
                    end
                end
            end
        end
    end
end
tab_trim = tab(:,4:end);
tab_lvl = tab_trim(:,2:2:end);
total = sum(tab_lvl,2);

sel = type(:)>0 & total(:)>0;

tab_lvl = tab_lvl(sel,:);
type = type(sel);
taxid = taxid(sel);
taxname = taxname(sel);

header_trim = header(4:L-3);
id_lvl = header_trim(2:2:end);
[id2,~] = AlignID(id_lvl,s_id2);
sample_lvl = sample(id2);

R.type = type;
R.taxid = taxid;
R.tab = tab_lvl;
R.sample = sample_lvl;
R.taxname = taxname;
R.type_legend = {'-2:R','-1:R1','0:U','1:D','2:D1','3:K','4:K1','5:P','6:P1','7:C','8:C1','9:O','10:O1','11:F','12:F1','13:G','14:G1','15:S','16:S1'};
end
function seq = typeNorm(x)
x1 = x(1);
n = length(x);
switch upper(x1)
    case 'U'
        seq = 0;
    case 'R'
        seq = -2;
    case 'D'
        seq = 1;
    case 'K'
        seq = 3;
    case 'P'
        seq = 5;
    case 'C'
        seq = 7;
    case 'O'
        seq = 9;
    case 'F'
        seq = 11;
    case 'G'
        seq = 13;
    case 'S'
        seq = 15;
end
if n>1
    seq=seq+1;
end
end
function y = removeTail(x)
n = length(x);
for i=n:-1:2
    if strcmpi(x(i-1:i),'_s')==1
        pos = i-1;
        break
    end
end
y = x(1:pos);
end