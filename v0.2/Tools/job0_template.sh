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
