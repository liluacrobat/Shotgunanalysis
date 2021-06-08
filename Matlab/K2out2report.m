function K2out2report(dirls,para)
load(para.rfile,'R','tb_ls');
F = R;
s = F.sample;
ctb = F.tab;
taxid = F.taxid;
taxname = F.taxname;
ns = length(s);
rtb_ls = cell(1,length(dirls));
tbframe = table(taxid,taxname,'VariableNames',{'taxid','taxname'});
for i=1:length(dirls)
    G = cell(1,ns);
    for k=1:ns
        filename = strcat(dirls{i},'/',s{k},'_kraken_output');
        f_tb = readtable(filename,'Delimiter','\t');
        contig_id = table2array(f_tb(:,2));
        contig_taxid = table2array(f_tb(:,3));
        
        cov_tb = readtable(strcat(para.dir2coverage,'/',s{k},'_aln_coverage.txt'),'Delimiter','\t');
        cov_id = table2array(cov_tb(:,1));
        cov_reads = table2array(cov_tb(:,4));
        if ~(length(unique(contig_id))==length(contig_id) && length(unique(cov_id))==length(cov_id) && length(contig_id)<=length(cov_id))
            disp('Error!!!!!!!!!!');
        end
        cov_filtered = cov_tb(:,[1,4]);
        contig_tb = table(contig_id,contig_taxid,'VariableNames',{'contig_id','tax_id'});
        h = size(contig_tb,1);
        contig_tb = innerjoin(contig_tb,cov_filtered,'Keys',1);
        if size(contig_tb,1)~=h
            disp('Error!!!!!!!!!!');
        end
        contig_tb = contig_tb(:,2:3);
        G{k} = groupsummary(contig_tb,'tax_id','sum');
    end
    tb = G{1};
    tb = tb(:,[1 3]);
    for q=2:length(G)
        tb2 = G{q};
        tb2 = tb2(:,[1 3]);
        tbjoin =outerjoin(tb,tb2,'MergeKeys',true,'Keys',1);
        tbjoin = reNaN(tbjoin,s);
        tb = tbjoin;
    end
    rtb_ls{i} = tb;
end
rtb_tmp = rtb_ls{1};
for i=2:length(rtb_ls)
    tbjoin_all =outerjoin(rtb_tmp,rtb_ls{i},'MergeKeys',true,'Keys',1);
    
    sd = [s(:);s(:)];
    for k=ns+1:ns*2
        sd{k} = [sd{k} '_d2'];
    end
    tbjoin_all = reNaN(tbjoin_all,sd);
    merged_count = table2array(tbjoin_all(:,2:1+ns))+table2array(tbjoin_all(:,ns+2:1+2*ns));
    merged_tb = array2table(merged_count,'VariableNames',s);
    
    tbjoin_joined = [tbjoin_all(:,1) merged_tb ];
    
    rtb_tmp = tbjoin_joined;
end
contig_taxid = table2array(rtb_tmp(:,1));
taxid_tt = cell(size(contig_taxid));
for p=1:length(contig_taxid)
    taxid_tt{p} = num2str(contig_taxid(p));
end
contig_taxid_tb = table(taxid_tt,'VariableNames',{'taxid'});

tbjoin_joined = [contig_taxid_tb rtb_tmp(:,2:end)];
tbjoin_F = innerjoin(tbframe,tbjoin_joined,'Keys',1);

Reads.taxid = table2array(tbjoin_F(:,1));
Reads.sample = s;
Reads.tab = table2array(tbjoin_F(:,3:end));
Reads.taxname = table2array(tbjoin_F(:,2));
% tbjoin_all.'VariableNames',[{'taxid'};s(:)]
writeResultTable(para.ofile,Reads.taxid,Reads.sample,Reads.tab,Reads.taxname);
save(para.ofile,'Reads');
end
function tbjoin = reNaN(tbjoin,s)
for k=2:size(tbjoin,2)
    tt = table2array(tbjoin(:,k));
    tt(isnan(tt)) = 0;
    tbjoin(:,k) = table(tt,'VariableNames',{'counts'});
end
nc = size(tbjoin,2);
VarName = cell(1,nc);
VarName{1} = 'taxid';
for k=2:nc
    VarName{k} = s{k-1};
end
tbjoin.Properties.VariableNames = VarName;
end
