#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="TaxUnmapped-__SAMPLE_ID__"
#SBATCH --output=TaxUnmapped-__SAMPLE_ID__.log


eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kraken2
module load bowtie2
echo '--------------------'
echo 'Start ...'

mkdir Reads
mkdir Reads/MAPPING
mkdir Reads/Mapped
mkdir Reads/Unmapped
mkdir Reads/Coverage

# Map reads to the contigs
bowtie2-build __WD__/Step1_Kneaddata/megahit_output/__SAMPLE_ID___out/__SAMPLE_ID__.contigs.fa Reads/MAPPING/__SAMPLE_ID___contigs
bowtie2 --threads 6 -x Reads/MAPPING/__SAMPLE_ID___contigs -1 __WD__/Step1_Kneaddata/kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_1.fastq -2 __WD__/Step1_Kneaddata/kneaddata_output/__SAMPLE_ID___R1_001_kneaddata_paired_2.fastq -S Reads/MAPPING/__SAMPLE_ID___aln.sam

samtools view -u -f 4 -F264 -bS Reads/MAPPING/__SAMPLE_ID___aln.sam > Reads/MAPPING/__SAMPLE_ID___aln-unmapped_tmp1.bam
samtools view -u -f 8 -F 260 -bS Reads/MAPPING/__SAMPLE_ID___aln.sam > Reads/MAPPING/__SAMPLE_ID___aln-unmapped_tmp2.bam
samtools view -u -f 12 -F 256 -bS Reads/MAPPING/__SAMPLE_ID___aln.sam > Reads/MAPPING/__SAMPLE_ID___aln-unmapped_tmp3.bam
samtools merge -u Reads/MAPPING/__SAMPLE_ID___aln-unmapped.bam Reads/MAPPING/__SAMPLE_ID___aln-unmapped_tmp1.bam Reads/MAPPING/__SAMPLE_ID___aln-unmapped_tmp2.bam Reads/MAPPING/__SAMPLE_ID___aln-unmapped_tmp3.bam
samtools sort -n Reads/MAPPING/__SAMPLE_ID___aln-unmapped.bam -o Reads/Unmapped/__SAMPLE_ID___aln-unmapped_sorted.bam

samtools bam2fq Reads/Unmapped/__SAMPLE_ID___aln-unmapped_sorted.bam > Reads/Unmapped/__SAMPLE_ID___aln-unmapped.PE.fastq
cat Reads/Unmapped/__SAMPLE_ID___aln-unmapped.PE.fastq | grep '^@.*/1$' -A 3 --no-group-separator > Reads/Unmapped/__SAMPLE_ID___R1_unmapped.fastq
cat Reads/Unmapped/__SAMPLE_ID___aln-unmapped.PE.fastq | grep '^@.*/2$' -A 3 --no-group-separator > Reads/Unmapped/__SAMPLE_ID___R2_unmapped.fastq

samtools view -u -f 1 -F 12 -bS Reads/MAPPING/__SAMPLE_ID___aln.sam > Reads/Mapped/__SAMPLE_ID___aln-mapped.bam
samtools sort Reads/Mapped/__SAMPLE_ID___aln-mapped.bam -o Reads/Mapped/__SAMPLE_ID___aln-mapped_sorted.bam
samtools bam2fq Reads/Mapped/__SAMPLE_ID___aln-mapped.bam > Reads/Mapped/__SAMPLE_ID___aln-mapped.PE.fastq

samtools coverage Reads/Mapped/__SAMPLE_ID___aln-mapped_sorted.bam -o Reads/Coverage/__SAMPLE_ID___aln_coverage.txt

samtools flagstat Reads/Unmapped/__SAMPLE_ID___aln-unmapped_sorted.bam > Reads/Coverage/__SAMPLE_ID___unmapped_flagstat.txt
samtools flagstat Reads/Mapped/__SAMPLE_ID___aln-mapped_sorted.bam > Reads/Coverage/__SAMPLE_ID___mapped_flagstat.txt
samtools flagstat Reads/MAPPING/__SAMPLE_ID___aln.sam > Reads/Coverage/__SAMPLE_ID___total_flagstat.txt

mkdir Reads/PE
mkdir Reads/PE/K2STD
# Working directory of the mapping process

mkdir Reads/PE/K2STD
mkdir Reads/PE/K2STD/uclassified
mkdir Reads/PE/K2STD/classified
mkdir Reads/PE/K2STD/output
mkdir Reads/PE/K2STD/report

kraken2 -db __K2STD__ --threads 6 --report Reads/PE/K2STD/report/__SAMPLE_ID__.report --unclassified-out Reads/PE/K2STD/uclassified/__SAMPLE_ID___unclassified#.fastq --classified-out Reads/PE/K2STD/classified/__SAMPLE_ID___classified#.fastq --output Reads/PE/K2STD/output/__SAMPLE_ID___kraken_output --paired Reads/Unmapped/__SAMPLE_ID___R1_unmapped.fastq Reads/Unmapped/__SAMPLE_ID___R2_unmapped.fastq

mkdir Reads/PE/K2NIH
mkdir Reads/PE/K2NIH/uclassified
mkdir Reads/PE/K2NIH/classified
mkdir Reads/PE/K2NIH/output
mkdir Reads/PE/K2NIH/report

kraken2 -db __K2NIH__ --threads 6 --report Reads/PE/K2NIH/report/__SAMPLE_ID__.report --unclassified-out Reads/PE/K2NIH/uclassified/__SAMPLE_ID___unclassified#.fastq --classified-out Reads/PE/K2NIH/classified/__SAMPLE_ID___classified#.fastq --output Reads/PE/K2NIH/output/__SAMPLE_ID___kraken_output --paired Reads/PE/K2STD/uclassified/__SAMPLE_ID___unclassified_1.fastq Reads/PE/K2STD/uclassified/__SAMPLE_ID___unclassified_2.fastq

echo 'End'
echo '--------------------'
