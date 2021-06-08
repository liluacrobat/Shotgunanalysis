#!/bin/sh
module load python/anaconda
mkdir sh
for f in *R1*.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1.fastq$/\1/");
        python Tools/build_slurm.py -s $b;
    done

cd sh
for f in $(ls *.sh);do sbatch $f;done

