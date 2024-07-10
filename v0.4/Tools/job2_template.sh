#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="TaxContig-__SAMPLE_ID__"
#SBATCH --output=TaxContig-__SAMPLE_ID__.log

module load gcc/11.2.0  openmpi/4.1.1
module load kraken2/2.1.2

echo '--------------------'
echo 'Start ...'
START='date +%s'

mkdir K2STD_result
mkdir K2STD_result/uclassified
mkdir K2STD_result/classified
mkdir K2STD_result/output
mkdir K2STD_result/report
echo 'K2 STD search ...'
kraken2 -db __K2STD__ --threads 6 --report K2STD_result/report/__SAMPLE_ID__.report --unclassified-out K2STD_result/uclassified/__SAMPLE_ID___unclassified.fa --classified-out K2STD_result/classified/__SAMPLE_ID___classified.fa --output K2STD_result/output/__SAMPLE_ID___kraken_output __WD__/Step1_Kneaddata/megahit_output/__SAMPLE_ID___out/__SAMPLE_ID__.contigs.fa
echo 'K2 STD search Succeed'
echo '--------------------'
echo 'K2 NIH search Succeed'
mkdir K2NIH_result
mkdir K2NIH_result/uclassified
mkdir K2NIH_result/classified
mkdir K2NIH_result/output
mkdir K2NIH_result/report

kraken2 -db __K2NIH__ --threads 6 --report K2NIH_result/report/__SAMPLE_ID__.report --unclassified-out K2NIH_result/uclassified/__SAMPLE_ID___unclassified.fa --classified-out K2NIH_result/classified/__SAMPLE_ID___classified.fa --output K2NIH_result/output/__SAMPLE_ID___kraken_output K2STD_result/uclassified/__SAMPLE_ID___unclassified.fa

echo 'K2 NIH search Succeed'
echo '--------------------'
