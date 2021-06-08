#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="Mothur-__SAMPLE_ID__"
#SBATCH --output=Mothur-__SAMPLE_ID__.log

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
export PATH=$PATH:/user/lli59/.local/bin

echo '--------------------'
echo 'Summarizing sequencing qualities ...'
START=`date +%s`

kneaddata --input ../__SAMPLE_ID___R1.fastq --input ../__SAMPLE_ID___R2.fastq -db /projects/academic/pidiazmo/projectsoftwares/kneaddata/hg37_ref -db /projects/academic/pidiazmo/projectsoftwares/kneaddata/mice_ref --output kneaddata_output --store-temp-output -t 12

END=`date +%s`
ELAPSED=$(( $END - $START ))
echo 'Summarizing sequencing qualities takes $ELAPSED s'


