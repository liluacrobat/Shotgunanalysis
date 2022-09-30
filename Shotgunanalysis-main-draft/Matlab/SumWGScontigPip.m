function SumWGScontigPip
clc;clear;close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SumWGScontigPip - Generate the WGS table using contig based pipeline
%
% Lu Li
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Assembly based pipeline
% % Step 1: Generate table of unmapped read
% path2dir = 'Unmappedreports';
% para.rfile = 'Assembly_pip/Unmapped/Assembly_pip_unmapped_Std_NIH_raw';
% para.vr = 0;
% para.s_flag = 0;
% para.tb_ls = {'Combined_std.report','Combined_NIH.report'};
% mkdir('Assembly_pip');
% mkdir('Assembly_pip/Unmapped');
% SumK2report2table(path2dir,para);

% % Step 2: Generate table of contigs
% path2dir = 'MegaHitreports';
% para.rfile = 'Assembly_pip/Mapped_contig/Assembly_pip_mapped_contig_Std_NIH_raw';
% para.vr = 0;
% para.s_flag = 0;
% para.tb_ls = {'Combined_std.report','Combined_NIH.report'};
% mkdir('Assembly_pip');
% mkdir('Assembly_pip/Mapped_contig');
% SumK2report2table(path2dir,para)

% % Step 3: Mapping reads to the contig and generate reports
% path2dir = 'MegaHitreports';
% para.rfile = 'Assembly_pip/Mapped_contig/Assembly_pip_mapped_contig_Std_NIH_raw';
% para.ofile = 'Assembly_pip/Mapped_read/Assembly_pip_mapped_read_Std_NIH_raw';
% para.vr = 0;
% para.s_flag = 0;
% para.dir2coverage = 'Coverage_all';
% mkdir('Assembly_pip/Mapped_read');
% dirls = {'MegaHit_contig_Kraken2Output_Std','MegaHit_contig_Kraken2Output_NIH'};
% K2out2report(dirls,para)

% Step 4: Combine the table from contig and reads
dir2ReadsTable = 'Assembly_pip/Unmapped/Assembly_pip_unmapped_Std_NIH_raw';
dir2ContigTable = 'Assembly_pip/Mapped_read/Assembly_pip_mapped_read_Std_NIH_raw';
dir2final = '/Users/luli/Documents/MATLAB/Shotgun_NIH/Assembly_pip/Combined_table';
load(dir2ReadsTable,'R');
UnmappedReads = R;
load(dir2ContigTable,'Reads');
MappedReads = Reads;

Mtx_unmapped = UnmappedReads.tab;

UnmappedReads_double = UnmappedReads;
UnmappedReads_double.tab = Mtx_unmapped*2;

table_ls{1} = MappedReads;
table_ls{2} = UnmappedReads_double;

R_combined = mergeK2Table(table_ls);
writeResultTable(dir2final,R_combined.taxid,R_combined.sample,R_combined.tab,R_combined.taxname);
save(dir2final,'R_combined');
end
function R = mergeK2Table(tb_ls)
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
