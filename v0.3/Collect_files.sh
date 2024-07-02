eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kneaddata/kneaddata

mkdir core_files
mkdir core_files/MegaHit_reports
mkdir core_files/Unmapped_reports
mkdir core_files/MegaHit_contig_Kraken2Output_STD
mkdir core_files/MegaHit_contig_Kraken2Output_NIH
echo 'Summarize KneadData results...'
kneaddata_read_count_table --input Step1_Kneaddata/kneaddata_output --output core_files/kneaddata_read_count_table.tsv
echo 'Summarize KneadData results. Done.'

conda activate /projects/academic/pidiazmo/projectsoftwares/kraken2
export PATH=$PATH:/projects/academic/pidiazmo/projectsoftwares/KrakenTools

echo 'Summarize Kraken2 taxonomy annotation of contigs...'
combine_kreports.py -r Step2_Kraken2_contig/K2STD_result/report/*.report -o core_files/MegaHit_reports/Contig_STD.report
combine_kreports.py -r Step2_Kraken2_contig/K2NIH_result/report/*.report -o core_files/MegaHit_reports/Contig_NIH.report
echo 'Summarize Kraken2 taxonomy annotation of contigs. Done.'

echo 'Summarize Kraken2 taxonomy annotation of unmapped reads...'
combine_kreports.py -r Step3_Kraken2_unmapped/Reads/PE/K2STD/report/*.report -o core_files/Unmapped_reports/Unmapped_STD.report
combine_kreports.py -r Step3_Kraken2_unmapped/Reads/PE/K2NIH/report/*.report -o core_files/Unmapped_reports/Unmapped_NIH.report
echo 'Summarize Kraken2 taxonomy annotation of unmapped reads. Done.'

echo 'Summarize Kraken2 taxonomy output of contigs...'
cp Step2_Kraken2_contig/K2STD_result/output core_files/MegaHit_contig_Kraken2Output_STD -r
cp Step2_Kraken2_contig/K2NIH_result/output core_files/MegaHit_contig_Kraken2Output_NIH -r
echo 'Summarize Kraken2 taxonomy output of contigs. Done.'

echo 'Summarize Kraken2 taxonomy output of unmapped reads...'
cp Step3_Kraken2_unmapped/Reads/PE/K2STD/output core_files/Unmapped_Kraken2Output_STD -r
cp Step3_Kraken2_unmapped/Reads/PE/K2NIH/output core_files/Unmapped_Kraken2Output_NIH -r
echo 'Summarize Kraken2 taxonomy output of unmapped reads. Done.'

echo 'Coverage of contigs...'
cp Step3_Kraken2_unmapped/Reads/Coverage core_files/Coverage_reads2contig -r
echo 'Coverage of contigs. Done.'


