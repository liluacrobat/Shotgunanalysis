#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=30000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="KD-TESTID"
#SBATCH --output=KD-TESTID.log

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kneaddata/kneaddata


echo '--------------------'
echo 'Filtering ...'

# If samples are from human, we can use only the hg37 database for host removal
kneaddata --input /panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-pidiazmo/lu_renew/Dam/fastq/TESTID_R1.fastq --input /panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-pidiazmo/lu_renew/Dam/fastq/TESTID_R2.fastq -db /projects/academic/pidiazmo/projectsoftwares/kneaddata/hg37_ref --output kneaddata_output -t 12 --trimmomatic /projects/academic/pidiazmo/projectsoftwares/kneaddata/kneaddata/bin/trimmomatic

echo 'Succeed'
echo '--------------------'
