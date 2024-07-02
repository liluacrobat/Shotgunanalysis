cp Combined_ready_table.txt.reformated.txt wgs_table.raw.txt
cp Combined_ready_table.txt.reformated.txt wgs_table.txt

biom convert -i wgs_table.txt -o wgs_table.biom --to-json --table-type "OTU table" --process-obs-metadata taxonomy

summarize_taxa.py -i wgs_table.biom -o tax_mapping_counts/ -L 2,3,4,5,6,7,8 -a
summarize_taxa.py -i wgs_table.biom -o tax_mapping_rel/ -L 2,3,4,5,6,7,8

summarize_taxa.py -i wgs_table.biom -o tax_mapping_counts/ -L 1 -a
summarize_taxa.py -i wgs_table.biom -o tax_mapping_rel/ -L 1


biom convert -i Archaea.txt -o Archaea.biom --to-json --table-type "OTU table" --process-obs-metadata taxonomy
mkdir Archaea
summarize_taxa.py -i Archaea.biom -o Archaea/tax_mapping_counts/ -L 3,4,5,6,7,8 -a
summarize_taxa.py -i Archaea.biom -o Archaea/tax_mapping_rel/ -L 3,4,5,6,7,8

biom convert -i Bacteria.txt -o Bacteria.biom --to-json --table-type "OTU table" --process-obs-metadata taxonomy
mkdir Bacteria
summarize_taxa.py -i Bacteria.biom -o Bacteria/tax_mapping_counts/ -L 3,4,5,6,7,8 -a
summarize_taxa.py -i Bacteria.biom -o Bacteria/tax_mapping_rel/ -L 3,4,5,6,7,8

biom convert -i Fungi.txt -o Fungi.biom --to-json --table-type "OTU table" --process-obs-metadata taxonomy
mkdir Fungi
summarize_taxa.py -i Fungi.biom -o Fungi/tax_mapping_counts/ -L 3,4,5,6,7,8 -a
summarize_taxa.py -i Fungi.biom -o Fungi/tax_mapping_rel/ -L 3,4,5,6,7,8

biom convert -i Viruses.txt -o Viruses.biom --to-json --table-type "OTU table" --process-obs-metadata taxonomy
mkdir Viruses
summarize_taxa.py -i Viruses.biom -o Viruses/tax_mapping_counts/ -L 2,3,4,5,6,7,8 -a
summarize_taxa.py -i Viruses.biom -o Viruses/tax_mapping_rel/ -L 2,3,4,5,6,7,8
