#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=20000
#SBATCH --ntasks-per-node=1
#SBATCH --job-name="UnZip"
#SBATCH --output=UnZip.log

mkdir __WD__/fastq
cp __WD__/gz/*.gz __WD__/fastq
cd __WD__/fastq
for x in $(ls *.gz);do gunzip $x;done
#sed 's/ 1.*/\/1/g' < raw_fastq/Sample_2_S2_S2_L001_R1_001.fastq > fastq/Sample_2_S2_S2_L001_R1_001.fastq
#sed 's/ 2.*/\/2/g' < raw_fastq/Sample_2_S2_S2_L001_R2_001.fastq > fastq/Sample_2_S2_S2_L001_R2_001.fastq
#
#sed 's/ 1:N:0//g' < raw_fastq/Sample_2_S2_S2_L001_R1_001.fastq > fastq2/Sample_2_S2_S2_L001_R1_001.fastq
#sed 's/ 2:N:0//g' < raw_fastq/Sample_2_S2_S2_L001_R2_001.fastq > fastq2/Sample_2_S2_S2_L001_R2_001.fastq
#
#

for file in raw_fastq/*R1_001.fastq;
do name=$(basename $file)
sed 's/ 1.*/\/1/g' $file > fastq2/$name
done
for file in raw_fastq/*R2_001.fastq;
do name=$(basename $file)
sed 's/ 2.*/\/2/g' $file > fastq2/$name
done
