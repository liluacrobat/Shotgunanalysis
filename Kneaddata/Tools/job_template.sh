#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="KD-__SAMPLE_ID__"
#SBATCH --output=KD-__SAMPLE_ID__.log

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kneaddata/kneaddata


echo '--------------------'
echo 'Filtering ...'

# If samples are from human, we can use only the hg37 database for host removal
kneaddata --input ../__SAMPLE_ID___R1.fastq --input ../__SAMPLE_ID___R2.fastq -db /projects/academic/pidiazmo/projectsoftwares/kneaddata/hg37_ref -db /projects/academic/pidiazmo/projectsoftwares/kneaddata/mice_ref --output kneaddata_output -t 12 --trimmomatic /projects/academic/pidiazmo/projectsoftwares/kneaddata/kneaddata/bin/trimmomatic

echo 'Succeed'
echo '--------------------'
