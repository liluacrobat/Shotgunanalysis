#!/bin/sh
DM = /panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-pidiazmo/lu_renew/Dam
cp /projects/academic/pidiazmo/lu/tmp/*.gz $DM/fastq
cd fastq
for x in ls *.gz;do gunzip $x;done


