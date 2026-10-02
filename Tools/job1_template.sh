#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60G
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="MGS-S1-__SAMPLE_ID__"
#SBATCH --output=MGS-S1-__SAMPLE_ID__.log

source /projects/academic/pidiazmo/projectsoftwares/nf-core-env/bin/activate
eval "$(/projects/academic/pidiazmo/projectsoftwares/miniconda3/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/pipeline_conda_env/metagenomic_pipeline

echo '--------------------'
echo 'Filtering ...'

kneaddata -i1 __WD__/fastq/__SAMPLE_ID___R1_001.fastq -i2 __WD__/fastq/__SAMPLE_ID___R2_001.fastq -db __KNEADATA_DB__ --output kneaddata_output -t 12 --trimmomatic __TRIMMOMATIC__
echo 'Filtering Succeed'
echo '--------------------'
echo 'Assembling ...'

mkdir megahit_output
megahit -1 kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_1.fastq -2 kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_2.fastq -o megahit_output/__SAMPLE_ID___out --out-prefix __SAMPLE_ID__
echo 'Assembling Succeed'
echo '--------------------'
