#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="TaxContig-__SAMPLE_ID__"
#SBATCH --output=TaxContig-__SAMPLE_ID__.log

source /projects/academic/pidiazmo/projectsoftwares/nf-core-env/bin/activate
eval "$(/projects/academic/pidiazmo/projectsoftwares/miniconda3/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/pipeline_conda_env/metagenomic_pipeline

echo '--------------------'
echo 'Start ...'
START='date +%s'

mkdir K2STD_result
mkdir K2STD_result/uclassified
mkdir K2STD_result/classified
mkdir K2STD_result/output
mkdir K2STD_result/report
echo 'K2 STD search ...'
krakenuniq \
  --db /projects/academic/pidiazmo/projectsoftwares/KrakenUniq_DB/MICROBIAL \
  __WD__/Step1_Kneaddata/megahit_output/__SAMPLE_ID___out/__SAMPLE_ID__.contigs.fa \
  --output K2STD_result/output/kunique___SAMPLE_ID___contig_kraken_output.tsv \
  --report-file K2STD_result/report/kunique___SAMPLE_ID__.report \
  --threads 12
echo 'KrakenUnique search succeed'

