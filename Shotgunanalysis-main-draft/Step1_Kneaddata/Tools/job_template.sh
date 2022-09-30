#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=30000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="KD-__SAMPLE_ID__"
#SBATCH --output=KD-__SAMPLE_ID__.log

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kneaddata/kneaddata


echo '--------------------'
echo 'Filtering ...'

# If samples are from human, we can use only the hg37 database for host removal
kneaddata --input __WD__/fastq/__SAMPLE_ID___R1_001.fastq --input __WD__/fastq/__SAMPLE_ID___R2_001.fastq -db __KNEADATA_DB__ --output kneaddata_output -t 12 --trimmomatic __TRIMMOMATIC__
echo 'Filtering Succeed'
echo '--------------------'
echo 'Assembling ...'
module load megahit

megahit -1 kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_1.fastq -2 kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_2.fastq -o __SAMPLE_ID___out --out-prefix __SAMPLE_ID__
echo 'Assembling Succeed'
echo '--------------------'
