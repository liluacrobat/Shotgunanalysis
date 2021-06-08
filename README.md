# Shotgunanalysis

## Filtering by Kneaddata
Modify the job template
```
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
kneaddata --input ../__SAMPLE_ID___R1.fastq --input ../__SAMPLE_ID___R2.fastq -db /projects/academic/pidiazmo/projectsoftwares/kneaddata/hg37_ref -db /projects/academic/pidiazmo/projectsoftwares/kneaddata/mice_ref --output kneaddata_output -t 12

echo 'Succeed.'
```
Run script to submit jobs
```
./generate_slurm_kneaddata.sh
```
## Merge contigs using MegaHit
```
./generate_slurm_kneaddata.sh
```
## Merge reports from Kraken2
download files and process with Matlab

```
eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kraken2
export PATH=$PATH:/projects/academic/pidiazmo/projectsoftwares/KrakenTools
combine_kreports.py -r report/*.report -o Combined_std.report
cd uclassified/sh
combine_kreports.py -r report/*.report -o Combined_NIH.report
```
```
module load megahit
```
## MegaHit
Calculate contig coverage and extract unassembled reads
```
eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kraken2
module load bowtie2

bowtie2-build $DHIT/OID3733.contigs.fa MAPPING/OID3733_contigs
```
