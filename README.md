# Shotgunanalysis

# Instructions for Using the Automated Job Submission Framework on CCR

## Overview

This framework automates job submission on CCR using Slurm. It includes:

- A **config.txt** file for setting environmental parameters.
- A **generate\_slurm\_all.sh** script for creating job scripts.
- A **Tools** folder containing a template for generating Slurm job scripts.

## Steps to Use the Framework

### 1. Configure the Environment

- Edit the **config.txt** file to specify required environmental parameters, such as:
  - Working directory
  - Database paths
  - Other task-specific settings

### 2. Modify the Job Script Template

- Adjust the script template located in the **Tools** folder to meet your specific analysis needs.

### 3. Upload Files to CCR

- Transfer all necessary files and folders (**config.txt**, **generate\_slurm\_all.sh**, **Tools folder**, and any required data) to the CCR directory where the analysis will be conducted.

### 4. Generate Slurm Job Scripts

- Run the following command in the working directory:
  ```bash
  bash generate_slurm_all.sh
  ```
  This script will create individual **.sh** job scripts for each task.

### 5. Load Required Modules

- Before submitting jobs, ensure that all required modules are loaded in your session, as CCR may not automatically load them when running the scripts. Use:
  ```bash
  module load <module_name>
  ```
  Replace `<module_name>` with the necessary module(s) for your analysis.

### 6. Submit Jobs to Slurm

- Navigate to each task directory and update script permissions:
  ```bash
  chmod 777 *.sh
  ```
- Submit all jobs in the directory using:
  ```bash
  for f in $(ls *.sh); do sbatch $f; done
  ```

## Notes

- If modules are not preloaded before submission, Slurm may report an error indicating that the module cannot be found.
- Always verify that job scripts are correctly generated before submitting them.
- Monitor job status using `squeue` and check logs for errors.

By following these steps, you can efficiently automate job submissions on CCR using this framework.


# Old note
## Check storage
```
ccrkinit
iquota -p /panasas/scratch/grp-sunstar
```
## Unzip files
```
for x in ls *.gz;do gunzip $x;done
```
## Useful command
Create symbolic link of files
```
ln -s pwd/* .
```
## Check sequence quality
```
module load fastqc/0.11.9-Java-11.0.16
module load gcc/11.2.0 openmpi/4.1.1
module load multiqc/1.14
mkdir fastqc
fastqc -o fastqc *.fastq
cd fastqc
multiqc . --interactive
```
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
kneaddata --input ../__SAMPLE_ID___R1.fastq --input ../__SAMPLE_ID___R2.fastq -db /projects/academic/pidiazmo/projectsoftwares/kneaddata/hg37_ref -db /projects/academic/pidiazmo/projectsoftwares/kneaddata/mice_ref --output kneaddata_output -t 12 --trimmomatic /projects/academic/pidiazmo/projectsoftwares/kneaddata/kneaddata/share/trimmomatic-0.39-2

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

###Collect data of contigs
```
mkdir contigs
for x in *_out;do cp $x/*.contigs.fa contigs/.;done
```
## Assign taxonomy to the contigs using Kraken2
Modify job template
```
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
```
Run script to submit jobs
```
./generate_slurm_K2contig.sh
```
## Map reads to contigs and assign taxonomy to unmapped reads
Modify job template
```
#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem=60000
#SBATCH --job-name="A-__SAMPLE_ID__"
#SBATCH --output=A-__SAMPLE_ID__.log

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kraken2
module load bowtie2
echo '--------------------'
echo 'Start ...'

DWK='/panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-pidiazmo/NIH_shotgun/NIH/kneaddata/sh/NIH_result_summary/kneaddata_output'
DHIT='/panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-pidiazmo/NIH_shotgun/NIH/MegaHit/sh/contigs'

mkdir MAPPING
mkdir Mapped
mkdir Unmapped
mkdir Coverage

# Map reads to the contigs
bowtie2-build $DHIT/__SAMPLE_ID__.contigs.fa MAPPING/__SAMPLE_ID___contigs
bowtie2 --threads 12 -x MAPPING/__SAMPLE_ID___contigs -1 $DWK/__SAMPLE_ID___R1_kneaddata_paired_1.fastq -2 $DWK/__SAMPLE_ID___R1_kneaddata_paired_2.fastq -S MAPPING/__SAMPLE_ID___aln.sam
# Unmapped,but mate unmapped, not primary alignment
samtools view -u -f 4 -F264 -bS MAPPING/__SAMPLE_ID___aln.sam > MAPPING/__SAMPLE_ID___aln-unmapped_tmp1.bam
# Mate unmapped, but read unmapped not primary alignment
samtools view -u -f 8 -F 260 -bS MAPPING/__SAMPLE_ID___aln.sam > MAPPING/__SAMPLE_ID___aln-unmapped_tmp2.bam
# Read unmapped and mate unmapped, but not primary alignment
samtools view -u -f 12 -F 256 -bS MAPPING/__SAMPLE_ID___aln.sam > MAPPING/__SAMPLE_ID___aln-unmapped_tmp3.bam
samtools merge -u MAPPING/__SAMPLE_ID___aln-unmapped.bam MAPPING/__SAMPLE_ID___aln-unmapped_tmp1.bam MAPPING/__SAMPLE_ID___aln-unmapped_tmp2.bam MAPPING/__SAMPLE_ID___aln-unmapped_tmp3.bam
samtools sort -n MAPPING/__SAMPLE_ID___aln-unmapped.bam -o Unmapped/__SAMPLE_ID___aln-unmapped_sorted.bam

samtools bam2fq Unmapped/__SAMPLE_ID___aln-unmapped_sorted.bam > Unmapped/__SAMPLE_ID___aln-unmapped.PE.fastq
cat Unmapped/__SAMPLE_ID___aln-unmapped.PE.fastq | grep '^@.*/1$' -A 3 --no-group-separator > Unmapped/__SAMPLE_ID___R1_unmapped.fastq
cat Unmapped/__SAMPLE_ID___aln-unmapped.PE.fastq | grep '^@.*/2$' -A 3 --no-group-separator > Unmapped/__SAMPLE_ID___R2_unmapped.fastq

samtools view -u -f 1 -F 12 -bS MAPPING/__SAMPLE_ID___aln.sam > Mapped/__SAMPLE_ID___aln-mapped.bam
samtools sort Mapped/__SAMPLE_ID___aln-mapped.bam -o Mapped/__SAMPLE_ID___aln-mapped_sorted.bam
samtools bam2fq Mapped/__SAMPLE_ID___aln-mapped.bam > Mapped/__SAMPLE_ID___aln-mapped.PE.fastq

samtools coverage Mapped/__SAMPLE_ID___aln-mapped_sorted.bam -o Coverage/__SAMPLE_ID___aln_coverage.txt

samtools flagstat Unmapped/__SAMPLE_ID___aln-unmapped_sorted.bam > Coverage/__SAMPLE_ID___unmapped_flagstat.txt
samtools flagstat Mapped/__SAMPLE_ID___aln-mapped_sorted.bam > Coverage/__SAMPLE_ID___mapped_flagstat.txt
samtools flagstat MAPPING/__SAMPLE_ID___aln.sam > Coverage/__SAMPLE_ID___total_flagstat.txt


mkdir PE
# Working directory of the mapping process
DW='/panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-pidiazmo/NIH_shotgun/NIH/AlignHit_pair/sh'

cd PE

DBNAME='/projects/academic/pidiazmo/projectsoftwares/kraken2_database/standard'
DWK=$DW/Unmapped

mkdir uclassified
mkdir classified
mkdir output
mkdir report

kraken2 -db $DBNAME --threads 12 --report report/__SAMPLE_ID__.report --unclassified-out uclassified/__SAMPLE_ID___unclassified#.fastq --classified-out classified/__SAMPLE_ID___classified#.fastq --output output/__SAMPLE_ID___kraken_output --paired $DWK/__SAMPLE_ID___R1_unmapped.fastq $DWK/__SAMPLE_ID___R2_unmapped.fastq

cd uclassified
DWK=$DW/PE/uclassified

mkdir sh
cd sh
mkdir uclassified
mkdir classified
mkdir output
mkdir report

DBNAME='/projects/academic/pidiazmo/metagenomic_datasets/JAMSdbApr2020_32Gbk2db/krakendb'
kraken2 -db $DBNAME --threads 12 --report report/__SAMPLE_ID__.report --unclassified-out uclassified/__SAMPLE_ID___unclassified#.fastq --classified-out classified/__SAMPLE_ID___classified#.fastq --output output/__SAMPLE_ID___kraken_output --paired $DWK/__SAMPLE_ID___unclassified_1.fastq $DWK/__SAMPLE_ID___unclassified_2.fastq

#cd uclassified
#DWK=$DWK/sh/uclassified
#
#mkdir sh
#cd sh
#mkdir uclassified
#mkdir classified
#mkdir output
#mkdir report
#
#DBNAME='/projects/academic/pidiazmo/projectsoftwares/kraken2_database/viral-jgi-krakendb-all'
#kraken2 -db $DBNAME --threads 12 --report report/__SAMPLE_ID__.report --unclassified-out uclassified/__SAMPLE_ID___unclassified#.fastq --classified-out classified/__SAMPLE_ID___classified#.fastq --output output/__SAMPLE_ID___kraken_output --paired $DWK/__SAMPLE_ID___unclassified_1.fastq $DWK/__SAMPLE_ID___unclassified_2.fastq

echo 'End'
echo '--------------------'

```
Run script to submit jobs
```
./generate_slurm_K2_unmapped.sh
```
## FastViromeExplorer to explore 
Update the database
```
eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kraken2
FV_dir=/projects/academic/pidiazmo/projectsoftwares/FastViromeExplorer-1.3/utility-scripts
bash $FV_dir/utility-scripts/generateGenomeList.sh IMGVR_all_nucleotides.fna img-vr-list.txt
kallisto index -i img-vr-kallisto-index.idx IMGVR_all_nucleotides.fna
```
The taxonomy reference of IMG/VR can be generate with Generate_IMG_VR_Tax.m in 'Matlab' folder

```
eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kraken2
FV_dir=/projects/academic/pidiazmo/projectsoftwares/FastViromeExplorer-1.3 # replace with the absolute path of FastViromeExplorer
VR_dir=/projects/academic/pidiazmo/metagenomic_datasets/IMG_VR/IMG_VR_2020-10-12_5.1
java -cp $FV_dir/bin FastViromeExplorer -1 $read1File -2 $read2File -i $VR_dir//path-to-index-file/imgvr-virus-kallisto-index-k31.idx -l imgvr-viruses-list.txt -o $outputDirectory
```
Modify the job template MegaHit to make contigs

'''
'''
## Download files and process with Matlab
Combine the report files
```
eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kraken2
export PATH=$PATH:/projects/academic/pidiazmo/projectsoftwares/KrakenTools
mkdir core_files
mkdir core_files/MegaHitreports
mkdir core_files/Unmappedreports
mkdir core_files/MegaHit_contig_Kraken2Output_Std
mkdir core_files/MegaHit_contig_Kraken2Output_NIH

combine_kreports.py -r Kraken2_contig/sh/report/*.report -o core_files/MegaHitreports/Combined_std.report
combine_kreports.py -r Kraken2_contig/sh/uclassified/sh/report/*.report -o core_files/MegaHitreports/Combined_NIH.report

combine_kreports.py -r Kraken2_unmapped/sh/PE/report/*.report -o core_files/Unmappedreports/Combined_std.report
combine_kreports.py -r Kraken2_unmapped/sh/PE/uclassified/sh/report/*.report -o core_files/Unmappedreports/Combined_NIH.report

cp Kraken2_contig/sh/output core_files/MegaHit_contig_Kraken2Output_Std -r
cp Kraken2_contig/sh/uclassified/sh/output core_files/MegaHit_contig_Kraken2Output_NIH -r
cp Kraken2_unmapped/sh/Coverage core_files/Coverage_all -r

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kneaddata/kneaddata
kneaddata_read_count_table --input Kneaddata/sh/kneaddata_output --output core_files/kneaddata_read_count_table.tsv

```
Download report files of contigs (MegaHitreports) and unmapped reads (Unmappedreports)
Download the Kraken2 output of contigs (MegaHit_contig_Kraken2Output_Std, MegaHit_contig_Kraken2Output_NIH)
Download the coverage files of the contigs (Coverage_all)
Run Matlab program to generate the final table
```
SumWGScontigPip.m
```
The final table corresponds to (number of read pairs)*2

# Output mapping realtionship
```
mkdir mapping_list
for x in $(ls *_aln-mapped_sorted.bam);do samtools view $x | awk -F'\t' '{ print $1 "\t" $3 }' > mapping_list/$x.txt; done
```
