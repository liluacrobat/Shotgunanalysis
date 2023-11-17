#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="H-__SAMPLE_ID__"
#SBATCH --output=H-__SAMPLE_ID__.log

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/metaphlan3

echo '--------------------'
echo 'Star ...'
cat __WD__/Step1_Kneaddata/__SAMPLE_ID___R1_001_kneaddata_paired_1.fastq __WD__/Step1_Kneaddata/__SAMPLE_ID___R1_001_kneaddata_paired_2.fastq > __SAMPLE_ID__merged_sample.fastq
humann --input __SAMPLE_ID__merged_sample.fastq --output __SAMPLE_ID___humann_result --threads 12 --search-mode uniref90 --bypass-nucleotide-search

echo 'Succeed'
echo '--------------------'
