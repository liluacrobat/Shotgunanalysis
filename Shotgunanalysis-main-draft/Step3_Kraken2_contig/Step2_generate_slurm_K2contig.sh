#!/bin/sh
module load python/anaconda
mkdir sh
for f in *.contigs.fa;
    do b=$(echo "$f" | sed "s/^\(.*\).contigs.fa$/\1/");
        python Tools/build_slurm.py -s $b;
    done

cd sh
for f in $(ls *.sh);do sbatch $f;done

