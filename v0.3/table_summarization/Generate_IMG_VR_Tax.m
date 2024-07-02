function Generate_IMG_VR_Tax
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the taxonomy file for IMG/VR database
% Input
%   sequence_infor: Sequence information
% Lu Li
% Last updated 06/14/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear;close all;
filename = 'IMGVR_all_Sequence_information.tsv';
fid1 = fopen(filename,'r');
fid2 = fopen('im-vr-tax.txt','w');
fid3 = fopen('im-vr-tax-uViG.txt','w');
line = fgetl(fid1);
while ~feof(fid1)
    line = fgetl(fid1);
    s = strsplit(line,'\t');
    vrid = strcat(s{1},'|',s{2},'|',s{3});
    tax =s{12};
    fprintf(fid2,'%s\t%s\n',vrid,tax);
    fprintf(fid3,'%s\t%s\n',s{1},tax);
end
end