#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem=60000
#SBATCH --job-name="K-__SAMPLE_ID__"
#SBATCH --output=K-__SAMPLE_ID__.log

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kraken2

echo '--------------------'
echo 'Start ...'
START='date +%s'
DBNAME=/projects/academic/pidiazmo/projectsoftwares/kraken2_database/standard
DWK=/panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-pidiazmo/NIH_shotgun/NIH/MegaHit/sh/contigs

mkdir uclassified
mkdir classified
mkdir output
mkdir report

#kraken2 -db $DBNAME --threads 12 --report report/__SAMPLE_ID__.report --unclassified-out uclassified/__SAMPLE_ID___unclassified.fa --classified-out classified/__SAMPLE_ID___classified.fa --output output/__SAMPLE_ID___kraken_output $DWK/__SAMPLE_ID__.contigs.fa

cd uclassified
DWK=$DWK/sh/uclassified
mkdir sh
cd sh
mkdir uclassified
mkdir classified
mkdir output
mkdir report

DBNAME=/projects/academic/pidiazmo/metagenomic_datasets/JAMSdbApr2020_32Gbk2db/krakendb
kraken2 -db $DBNAME --threads 12 --report report/__SAMPLE_ID__.report --unclassified-out uclassified/__SAMPLE_ID___unclassified.fa --classified-out classified/__SAMPLE_ID___classified.fa --output output/__SAMPLE_ID___kraken_output $DWK/__SAMPLE_ID___unclassified.fa

#cd uclassified
#DWK=$DWK/sh/uclassified

#mkdir sh
#cd sh
#mkdir uclassified
#mkdir classified
#mkdir output
#mkdir report
#
#DBNAME='/projects/academic/pidiazmo/projectsoftwares/kraken2_database/viral-jgi-krakendb-all'
#kraken2 -db $DBNAME --threads 12 --report report/__SAMPLE_ID__.report --unclassified-out uclassified/__SAMPLE_ID___unclassified.fa --classified-out classified/__SAMPLE_ID___classified.fa --output output/__SAMPLE_ID___kraken_output $DWK/__SAMPLE_ID___unclassified.fa

echo 'End'


