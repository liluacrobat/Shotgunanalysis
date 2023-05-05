#!/bin/sh
tmux
cd fastq
for x in $(ls *.gz);do gunzip $x;done



