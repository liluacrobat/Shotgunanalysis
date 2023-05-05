#!/bin/sh
#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=36:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem=60000
#SBATCH --job-name="ContigTax-__SAMPLE_ID__"
#SBATCH --output=ContigTax-__SAMPLE_ID__.log

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kraken2

echo '--------------------'
echo 'Start ...'
START='date +%s'

mkdir K2STD_result
mkdir K2STD_result/uclassified
mkdir K2STD_result/classified
mkdir K2STD_result/output
mkdir K2STD_result/report
echo 'K2 STD search ...'
kraken2 -db __K2STD__ --threads 12 --report K2STD_result/report/__SAMPLE_ID__.report --unclassified-out K2STD_result/uclassified/__SAMPLE_ID___unclassified.fa --classified-out K2STD_result/classified/__SAMPLE_ID___classified.fa --output K2STD_result/output/__SAMPLE_ID___kraken_output __WD__/Step1_Kneaddata/megahit_output/__SAMPLE_ID___out/__SAMPLE_ID__.contigs.fa
echo 'K2 STD search Succeed'

echo '--------------------'
echo 'K2 NIH search Succeed'
mkdir K2NIH_result
mkdir K2NIH_result/uclassified
mkdir K2NIH_result/classified
mkdir K2NIH_result/output
mkdir K2NIH_result/report

kraken2 -db __K2NIH__ --threads 12 --report K2NIH_result/report/__SAMPLE_ID__.report --unclassified-out K2NIH_result/uclassified/__SAMPLE_ID___unclassified.fa --classified-out K2NIH_result/classified/__SAMPLE_ID___classified.fa --output K2NIH_result/output/__SAMPLE_ID___kraken_output K2STD_result/uclassified/__SAMPLE_ID___unclassified.fa

echo 'K2 NIH search Succeed'
echo '--------------------'
