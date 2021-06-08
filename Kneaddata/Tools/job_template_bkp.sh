#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="Mothur-__SAMPLE_ID__"
#SBATCH --output=Mothur-__SAMPLE_ID__.log

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kneaddata/kneaddata
export PATH=$PATH:/projects/academic/pidiazmo/projectsoftwares/kneaddata/kneaddata/share/trimmomatic-0.39-1

echo '--------------------'
echo 'Summarizing sequencing qualities ...'
START=`date +%s`

kneaddata --input ../__SAMPLE_ID___R1.fastq --input ../__SAMPLE_ID___R2.fastq -db /projects/academic/pidiazmo/projectsoftwares/kneaddata/hg37_ref --output kneaddata_output --store-temp-output -t 12

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/metaphlan3
unset PYTHONPATH

mkdir genome_output
mkdir bowtie2_output

metaphlan kneaddata_output/__SAMPLE_ID___R1_kneaddata_paired_1.fastq,kneaddata_output/__SAMPLE_ID___R1_kneaddata_paired_2.fastq --bowtie2out bowtie2_output/__SAMPLE_ID___metagenome.bowtie2.bz2 --input_type fastq -o genome_output/__SAMPLE_ID___profiled_metagenome.txt --nproc 12

END=`date +%s`
ELAPSED=$(( $END - $START ))
echo 'Summarizing sequencing qualities takes $ELAPSED s'


