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
echo '--------------------'
```
Run script to submit jobs
```
./generate_slurm_kneaddata.sh
```
## Make contigs using MegaHit
Modify the job template MegaHit to make contigs
```
#!/bin/sh
#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="M-__SAMPLE_ID__"
#SBATCH --output=M-__SAMPLE_ID__.log

module load megahit
# Replace DWK to the directory of kneaddata_output
DWK='/panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-pidiazmo/NIH_shotgun/NIH/kneaddata/sh/NIH_result_summary/kneaddata_output'

echo '--------------------'
echo 'Start ...'

megahit -1 $DWK/__SAMPLE_ID___R1_kneaddata_paired_1.fastq -2 $DWK/__SAMPLE_ID___R1_kneaddata_paired_2.fastq -o __SAMPLE_ID___out  --out-prefix __SAMPLE_ID__

echo 'End'
echo '--------------------'

```
Run script to submit jobs
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
