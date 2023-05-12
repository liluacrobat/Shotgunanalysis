#!/bin/sh
module load python/anaconda
ln -s fastq/*.fastq .
mkdir sh
mkdir Step1_Kneaddata
mkdir Step2__Kraken2_contig
mkdir Step3_Kraken2_unmapped
for f in *R1_001.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b -t job1_template.sh -d Step1_Kneaddata;
    done

for f in *R1*.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b -t job2_template.sh -d Step2__Kraken2_contig;
    done
    
for f in *R1*.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm2.py -s $b -t job3_template.sh;
    done
cd sh
chmod 777 *.sh

for f in $(ls *.sh);do sbatch $f;done
