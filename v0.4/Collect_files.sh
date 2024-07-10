module load gcc/11.2.0
module load kneaddata/0.12.0

mkdir core_files
mkdir core_files/MegaHit_reports
mkdir core_files/Unmapped_reports
mkdir core_files/MegaHit_contig_Kraken2Output_STD
mkdir core_files/MegaHit_contig_Kraken2Output_NIH
echo 'Summarize KneadData results...'
kneaddata_read_count_table --input Step1_Kneaddata/kneaddata_output --output core_files/kneaddata_read_count_table.tsv
echo 'Summarize KneadData results. Done.'

module load openmpi/4.1.1
module load kraken2/2.1.2
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

echo 'Collect HUMAnN files...'

mkdir core_files/HUMAnN_tsv_table_raw
mkdir core_files/HUMAnN_tsv_table_raw/genefamilies
mkdir core_files/HUMAnN_tsv_table_raw/pathabundance
mkdir core_files/HUMAnN_tsv_table_raw/pathcoverage

for x in Step4_HUMAnN/*_humann_result; do cp $x/*_genefamilies.tsv core_files/HUMAnN_tsv_table_raw/genefamilies/.;done
for x in Step4_HUMAnN/*_humann_result; do cp $x/*_pathabundance.tsv core_files/HUMAnN_tsv_table_raw/pathabundance/.;done
for x in Step4_HUMAnN/*_humann_result; do cp $x/*_pathcoverage.tsv core_files/HUMAnN_tsv_table_raw/pathcoverage/.;done
cd core_files/HUMAnN_tsv_table_raw

module load gcc/11.2.0  openmpi/4.1.1
module load humann/3.6

humann_join_tables --input genefamilies --output genefamilies_joined.tsv
humann_join_tables --input pathabundance --output pathabundance_joined.tsv
humann_join_tables --input pathcoverage --output pathcoverage_joined.tsv

humann_split_stratified_table --input genefamilies_joined.tsv --output genefamilies_split_stratified
humann_split_stratified_table --input pathabundance_joined.tsv --output pathabundance_split_stratified
humann_split_stratified_table --input pathcoverage_joined.tsv --output pathcoverage_split_stratified

cd genefamilies_split_stratified
humann_regroup_table -i genefamilies_joined_unstratified.tsv -o genefamilies_joined_unstratified_GO.tsv -c /projects/academic/pidiazmo/projectsoftwares/HUMAnN_database/utility_mapping/map_go_uniref90.txt.gz
humann_regroup_table -i genefamilies_joined_unstratified.tsv -o genefamilies_joined_unstratified_KO.tsv -c /projects/academic/pidiazmo/projectsoftwares/HUMAnN_database/utility_mapping/map_ko_uniref90.txt.gz
humann_regroup_table -i genefamilies_joined_unstratified.tsv -o genefamilies_joined_unstratified_level4ec.tsv -c /projects/academic/pidiazmo/projectsoftwares/HUMAnN_database/utility_mapping/map_level4ec_uniref90.txt.gz
humann_regroup_table -i genefamilies_joined_unstratified.tsv -o genefamilies_joined_unstratified_MetaCyCreaction.tsv -g uniref90_rxn
humann_regroup_table -i genefamilies_joined_unstratified_level4ec.tsv -o genefamilies_joined_unstratified_KEGGpwy.tsv -c /projects/academic/pidiazmo/projectsoftwares/HUMAnN_database/utility_mapping/ec_to_pwy_renamed.txt


humann_rename_table --i genefamilies_joined_unstratified_GO.tsv -c /projects/academic/pidiazmo/projectsoftwares/HUMAnN_database/utility_mapping/map_go_name.txt.gz -o genefamilies_joined_unstratified_GO_w_anno.tsv
humann_rename_table --i genefamilies_joined_unstratified_KO.tsv -c /projects/academic/pidiazmo/projectsoftwares/HUMAnN_database/utility_mapping/map_ko_name.txt.gz -o genefamilies_joined_unstratified_KO_w_anno.tsv
humann_rename_table --i genefamilies_joined_unstratified_level4ec.tsv -c /projects/academic/pidiazmo/projectsoftwares/HUMAnN_database/utility_mapping/map_ec_name.txt.gz -o genefamilies_joined_unstratified_level4ec_w_anno.tsv
humann_rename_table --i genefamilies_joined_unstratified_MetaCyCreaction.tsv -n metacyc-rxn -o genefamilies_joined_unstratified_MetaCyCreaction_w_anno.tsv
humann_rename_table --i genefamilies_joined_unstratified.tsv -c /projects/academic/pidiazmo/projectsoftwares/HUMAnN_database/utility_mapping/map_uniref90_name.txt.bz2 -o genefamilies_joined_unstratified_UniRef90_w_anno.tsv
humann_rename_table --i genefamilies_joined_unstratified_KEGGpwy.tsv -c /projects/academic/pidiazmo/projectsoftwares/HUMAnN_database/utility_mapping/keggc.txt -o genefamilies_joined_unstratified_KEGGpwy_w_anno.tsv
cd ..
cd ..
cd ..
echo 'Collect HUMAnN files. Done.'
