#!/bin/sh
DM = /panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-pidiazmo/Dam
mkdir $DM/fastq
cp /panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-pidiazmo/Dam/*.gz $DM/fastq
cd fastq
for x in ls *.gz;do gunzip $x;done


