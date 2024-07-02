#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="KD-__SAMPLE_ID__"
#SBATCH --output=KD-__SAMPLE_ID__.log

module load gcc/11.2.0
module load kneaddata/0.12.0

echo '--------------------'
echo 'Filtering ...'

# If samples are from human, we can use only the hg37 database for host removal
sed 's/ 1.*/\/1/g' __WD__/raw_fastq/__SAMPLE_ID___R1_001.fastq > fastq/__SAMPLE_ID___R1_001.fastq
sed 's/ 2.*/\/2/g' __WD__/raw_fastq/__SAMPLE_ID___R2_001.fastq > fastq/__SAMPLE_ID___R2_001.fastq

kneaddata -i1 __WD__/fastq/__SAMPLE_ID___R1_001.fastq -i2 __WD__/fastq/__SAMPLE_ID___R2_001.fastq -db __KNEADATA_DB__ --output kneaddata_output -t 12 --trimmomatic __TRIMMOMATIC__
echo 'Filtering Succeed'
echo '--------------------'
echo 'Assembling ...'

module load megahit/1.2.9

mkdir megahit_output
megahit -1 kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_1.fastq -2 kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_2.fastq -o megahit_output/__SAMPLE_ID___out --out-prefix __SAMPLE_ID__
echo 'Assembling Succeed'
echo '--------------------'
