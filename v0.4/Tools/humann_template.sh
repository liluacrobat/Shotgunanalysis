#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="H-__SAMPLE_ID__"
#SBATCH --output=H-__SAMPLE_ID__.log


module load gcc/11.2.0  openmpi/4.1.1
module load humann/3.6

echo '--------------------'
echo 'Star ...'
cat __WD__/Step1_Kneaddata/kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_1.fastq __WD__/Step1_Kneaddata/kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_2.fastq > __SAMPLE_ID__merged_sample.fastq
humann --input __SAMPLE_ID__merged_sample.fastq --output __SAMPLE_ID___humann_result --threads 12 --search-mode uniref90 --bypass-nucleotide-search --protein-database /projects/academic/pidiazmo/projectsoftwares/HUMAnN_database/uniref

echo 'Succeed'
echo '--------------------'
