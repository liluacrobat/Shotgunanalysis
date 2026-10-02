module load gcc/11.2.0
module load kneaddata/0.12.0

source /projects/academic/pidiazmo/projectsoftwares/nf-core-env/bin/activate
eval "$(/projects/academic/pidiazmo/projectsoftwares/miniconda3/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/pipeline_conda_env/metagenomic_pipeline

mkdir core_files
mkdir core_files/MegaHit_reports
mkdir core_files/Unmapped_reports
mkdir core_files/MegaHit_contig_Kraken2Output_STD
mkdir core_files/Unmapped_Kraken2Output_STD

echo 'Summarize KneadData results...'
kneaddata_read_count_table --input Step1_Kneaddata/kneaddata_output --output core_files/kneaddata_read_count_table.tsv
echo 'Summarize KneadData results. Done.'

export PATH=$PATH:/projects/academic/pidiazmo/projectsoftwares/KrakenTools

echo 'Summarize KrakenUnique taxonomy annotation of contigs...'
combine_kreports_kUnique.py -r Step2_Kraken2_contig/K2STD_result/report/*.report -o core_files/MegaHit_reports/Contig_STD.report
echo 'Summarize Kraken2 taxonomy annotation of contigs. Done.'

echo 'Summarize Kraken2 taxonomy annotation of unmapped reads...'
combine_kreports_kUnique.py -r Step3_Kraken2_unmapped/*.report -o core_files/Unmapped_reports/Unmapped_STD.report
echo 'Summarize Kraken2 taxonomy annotation of unmapped reads. Done.'

echo 'Summarize Kraken2 taxonomy output of contigs...'
cp Step2_Kraken2_contig/K2STD_result/output core_files/MegaHit_contig_Kraken2Output_STD -r
echo 'Summarize Kraken2 taxonomy output of contigs. Done.'

echo 'Summarize Kraken2 taxonomy output of unmapped reads...'
cp Step3_Kraken2_unmapped/krakenuniq_*_unmapped.tsv core_files/Unmapped_Kraken2Output_STD -r
echo 'Summarize Kraken2 taxonomy output of unmapped reads. Done.'

echo 'Coverage of contigs...'
cp Step3_Kraken2_unmapped/Reads/Coverage core_files/Coverage_reads2contig -r
echo 'Coverage of contigs. Done.'


echo 'Collect additional files...'
mkdir core_files/additional
mkdir core_files/additional/clean_paired
mv Step1_Kneaddata/kneaddata_output/*_kneaddata_paired_1.fastq core_files/additional/clean_paired/.
mv Step1_Kneaddata/kneaddata_output/*_kneaddata_paired_2.fastq core_files/additional/clean_paired/.

mkdir core_files/additional/contig
for x in Step1_Kneaddata/megahit_output/*_out;do mv $x/*.contigs.fa core_files/additional/contig/.;done
echo 'Collect additional files. Done.'
