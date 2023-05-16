cp Combined_ready_table.txt.reformated.txt wgs_table.raw.txt
cp Combined_ready_table.txt.reformated.txt wgs_table.txt

biom convert -i wgs_table.txt -o wgs_table.biom --to-json --table-type "OTU table" --process-obs-metadata taxonomy

summarize_taxa.py -i wgs_table.biom -o tax_mapping_counts/ -L 2,3,4,5,6,7,8 -a
summarize_taxa.py -i wgs_table.biom -o tax_mapping_rel/ -L 2,3,4,5,6,7,8
