#!/bin/sh
module load python/anaconda

mkdir sh
for f in *R1*.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b -t job1_template.sh;
    done

for f in *R1*.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b -t job2_template.sh;
    done
    
for f in *R1*.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm2.py -s $b -t job3_template.sh;
    done
cd sh
chmod 777 *.sh

for f in $(ls *.sh);do sbatch $f;done
