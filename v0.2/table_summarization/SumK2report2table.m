function SumK2report2table(path2dir,para)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SumK2report2table - Combine the reports from Kraken2
% Input
%  path2dir: path to the directory of Kraken2 reports, the directory should
%            only inlude the combined report files of Kraken2
%  para
%    - vr: 1, include the results against IMG/VR database; 0, otherwise
%    - s_flag: 1, remove _S added to the filename by the platform;
%              0, otherwise
% Lu Li
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    para = [];
end
if ~isfield(para,'vr')
    para.vr = 0;
end
if ~isfield(para,'s_flag')
    para.s_flag = 0;
end
if ~isfield(para,'tb_ls')
    para.tb_ls = {'Combined_std.report','Combined_NIH.report'};
end
for i=1:length(para.tb_ls)
    path2file = strcat(path2dir,'/',para.tb_ls{i});
    tb_ls{i} = readK2table(path2file,para.s_flag);
end
R = mergeTable(tb_ls);
writeResultTable(para.rfile,R.taxid,R.sample,R.tab,R.taxname);
save(para.rfile,'R','tb_ls');
end
function R = mergeTable(tb_ls)
R = tb_ls{1};
n = length(tb_ls);
for i=2:n
    Rs = R.sample;
    T = tb_ls{i};
    Ts = T.sample;
    if length(R.sample)~=length(T.sample)
        disp('Error!!!!!!!!');
        break
    end
    Rtb = R.tab;
    Ttb = T.tab;
    Rid = R.taxid;
    Tid = T.taxid;
    Rtax = R.taxname;
    Ttax = T.taxname;
    
    id0 = AlignID(Rs,Ts);
    Ttb_sorted = Ttb(:,id0);

    set2 = setdiff(Tid,Rid);

    id1 = AlignID(Rid,Tid);
    tab1 = Rtb;
    tab1(id1~=0,:) = tab1(id1~=0,:)+Ttb_sorted(id1(id1~=0),:);
    
    id2 = AlignID(set2,Tid);
    tab_set2 = Ttb_sorted(id2,:);
    
    taxid = [Rid(:);set2(:)];
    taxname = [Rtax;Ttax(id2)];
    tab = [tab1;tab_set2];

    check = sum(abs(sum(tab,1)-sum(Rtb,1)-sum(Ttb_sorted,1)));
    if check~=0
        disp('Error!!!!!!!!');
    end
    
    F.taxid = taxid;
    F.taxname = taxname;
    F.tab = tab;
    F.sample = Rs;
    R = F;
end
end
function idx12 = AlignID(ID1,ID2)
% 2->1
n1=length(ID1);
n2=length(ID2);

trimed_1 = cell(size(ID1));
for i=1:n1
    trimed_1{i} =strtrim(ID1{i});
end
trimed_2 = cell(size(ID2));
for i=1:n2
    trimed_2{i} =strtrim(ID2{i});
end
% [ia,ic] = ismember(trimed_1,trimed_2);

% 2->1
n1=length(ID1);
idx12=zeros(n1,1);
[la1,lc1] = ismember(trimed_1,trimed_2);
idx12(la1) = lc1(la1);
% n2=length(ID2);
% [la2,lc2] = ismember(ID2,ID1);
% idx21=zeros(n2,1);
% idx21(la2) = lc2(la2);
end