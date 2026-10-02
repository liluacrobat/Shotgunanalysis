#!/bin/sh
source /projects/academic/pidiazmo/projectsoftwares/nf-core-env/bin/activate
eval "$(/projects/academic/pidiazmo/projectsoftwares/miniconda3/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/pipeline_conda_env/metagenomic_pipeline


mkdir Step1_Kneaddata
mkdir Step2_Kraken2_contig
mkdir Step3_Kraken2_unmapped
ln -s fastq/*.fastq .
for f in *R1_001.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b -t job1_template.sh -d Step1_Kneaddata;
    done

for f in *R1_001.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b -t job2_template.sh -d Step2_Kraken2_contig;
    done
    
for f in *R1_001.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\)_R1_001.fastq$/\1/");
        python Tools/build_slurm.py -s $b -t job3_template.sh -d Step3_Kraken2_unmapped;
    done

