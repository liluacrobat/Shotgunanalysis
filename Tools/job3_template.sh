#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60G
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="TaxUnmapped-__SAMPLE_ID__"
#SBATCH --output=TaxUnmapped-__SAMPLE_ID__.log

source /projects/academic/pidiazmo/projectsoftwares/nf-core-env/bin/activate
eval "$(/projects/academic/pidiazmo/projectsoftwares/miniconda3/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/pipeline_conda_env/metagenomic_pipeline
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

# Self unmapped, mate mapped
samtools view -u -f 4 -F 264 -bS Reads/MAPPING/__SAMPLE_ID___aln.sam > Reads/MAPPING/__SAMPLE_ID___aln-unmapped_tmp1.bam
# Self mapped, mate unmapped
samtools view -u -f 8 -F 260 -bS Reads/MAPPING/__SAMPLE_ID___aln.sam > Reads/MAPPING/__SAMPLE_ID___aln-unmapped_tmp2.bam
# Both unmapped
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
krakenuniq \
  --db /projects/academic/pidiazmo/projectsoftwares/KrakenUniq_DB/MICROBIAL \
  --paired \
  Reads/Unmapped/__SAMPLE_ID___R1_unmapped.fastq \
  Reads/Unmapped/__SAMPLE_ID___R2_unmapped.fastq \
  --output krakenuniq___SAMPLE_ID___unmapped.tsv \
  --report-file krakenuniq___SAMPLE_ID___unmapped.report \
  --threads 12

echo 'End'
echo '--------------------'
