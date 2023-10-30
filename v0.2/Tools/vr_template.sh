#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="VIR-__SAMPLE_ID__"
#SBATCH --output=VIR-__SAMPLE_ID__.log

echo '--------------------'
eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/virus
mkdir output/__SAMPLE_ID__
FV_dir=/projects/academic/pidiazmo/projectsoftwares/FastViromeExplorer-1.3 # replace with the absolute path of FastViromeExplorer
VR_dir=/projects/academic/pidiazmo/metagenomic_datasets/IMG_VR/IMG_VR_2020-10-12_5.1
java -cp $FV_dir/bin FastViromeExplorer -1 /panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-sunstar/lu_09_29_2023/Step1_Kneaddata/kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_1.fastq -2 /panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-sunstar/lu_09_29_2023/Step1_Kneaddata/kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_2.fastq -i /projects/academic/pidiazmo/projectsoftwares/FastViromeExplorer_database/imgvr-virus-kallisto-index-k31.idx -l /projects/academic/pidiazmo/projectsoftwares/FastViromeExplorer_database/imgvr-viruses-list.txt -o output/__SAMPLE_ID__

echo 'Succeed'
echo '--------------------'
