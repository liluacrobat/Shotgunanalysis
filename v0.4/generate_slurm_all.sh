#!/bin/sh
module load gcc/11.2.0 openmpi/4.1.1
module load scipy-bundle/2021.10
ln -s fastq/*.fastq .

mkdir Step1_Kneaddata
mkdir Step2_Kraken2_contig
mkdir Step3_Kraken2_unmapped
for f in *R1_001.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b -t job1_template.sh -d Step1_Kneaddata;
    done

for f in *R1*.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b -t job2_template.sh -d Step2_Kraken2_contig;
    done
    
for f in *R1*.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b -t job3_template.sh -d Step3_Kraken2_unmapped;
    done
    
mkdir Step4_HUMAnN
for f in *R1*.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b -t humann_template.sh -d Step4_HUMAnN;
    done
#cd Step1_Kneaddata
chmod 777 *.sh

for f in $(ls *.sh);do sbatch $f;done
