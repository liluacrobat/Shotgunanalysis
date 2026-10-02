# Shotgun Metagenomic Processing Pipeline Instructions

This workflow processes paired-end Illumina shotgun metagenomic reads on a SLURM cluster, then combines taxonomy assignments into abundance tables locally. It uses KneadData for trimming and host removal, MEGAHIT for per-sample assembly, KrakenUniq for taxonomy assignment, Bowtie2 and SAMtools for mapping, MATLAB for table assembly, and legacy QIIME for taxonomic summaries.

The numbered instructions follow the same configure, generate, inspect, submit, and verify approach as the hybrid-assembly guide. Complete the corrections in section 1 before using this workflow with a new dataset.

## Workflow

```text
Paired FASTQ reads
  -> Job 1: KneadData -> MEGAHIT contigs
  -> Job 2: KrakenUniq classification of contigs
  -> Job 3: map cleaned pairs to contigs
       both mates mapped -> contig read counts
       either mate unmapped -> classify both mates with KrakenUniq
  -> Collect key reports, classifications, and coverage files
  -> MATLAB: mapped reads + 2 x classified residual pairs
  -> Reformat taxonomy -> BIOM -> taxonomic level tables
```

Job 1 includes assembly. Job 2 only classifies contigs. After job 1 succeeds for a sample, jobs 2 and 3 can run concurrently; job 3 does not read job 2 outputs. Collection and table summarization require both jobs to finish successfully.

The tool is KrakenUniq, invoked as `krakenuniq`. Folder names containing `Kraken2` or `K2STD` are retained for compatibility with the supplied scripts; they do not identify the executable or database used.

## 1 Prepare the scripts and dependencies

The supplied files require the following corrections. These are edits to make before running the commands below, not changes already applied to the pipeline.

Use `#!/bin/bash` for the generator and job templates. In job templates, place `set -euo pipefail` after the last SBATCH directive, and check that the site's environment activation works with these settings. Replace shared-directory `mkdir` calls with `mkdir -p`. If activation is incompatible with strict mode, initialize the environment first and enable strict mode immediately afterward. Success messages must only follow successful commands.

Check all site-specific activation paths, software installations, SLURM partition, QoS, runtime, and memory settings. The templates request 12 tasks on one node and roughly 60 GB for up to 71 hours.

## 2 Configure input paths and reference databases

Work from the pipeline root on the cluster. Place uncompressed paired FASTQ files in `fastq/`, using this naming pattern:

```text
fastq/SAMPLE_ID_R1_001.fastq
fastq/SAMPLE_ID_R2_001.fastq
```

Retain the entire sample identifier, including `_S` and its number when present. The current generator does not discover `.fastq.gz` files. Combine multiple sequencing lanes consistently before using this single-pair naming scheme, or adapt the generator and templates for multiple lanes.

Edit `config.txt`. `WD` must be the absolute cluster path to the pipeline root, not the local download directory. For example:

```text
WD = /path/to/shotgun_pipeline
PARTITION = general-compute
KNEADATA_DB = /path/to/host_reference
TRIMMOMATIC = /path/to/Trimmomatic-0.39
```

Do not add quotation marks around these config values with the current parser. Avoid whitespace in paths and sample identifiers. The templates expand the values directly into shell commands.

`KNEADATA_DB` is the existing spelling of the configuration key. For two host databases, the current template permits a value containing `/path/to/human_reference -db /path/to/mouse_reference`. Choose host references appropriate to the study and record their versions; do not use both automatically for every study.

Jobs 2 and 3 use the hard-coded KrakenUniq database path ending in `KrakenUniq_DB/MICROBIAL`. Change both templates to the same valid KrakenUniq database. `K2STD` and `K2NIH` in the current config do not control these jobs. Record the actual database content and build date; the supplied files do not establish them.

Verify a sample and the required tools after activating the site's processing environment:

```bash
test -s fastq/SAMPLE_ID_R1_001.fastq
test -s fastq/SAMPLE_ID_R2_001.fastq
command -v python kneaddata megahit krakenuniq
command -v bowtie2 bowtie2-build samtools
command -v kneaddata_read_count_table
command -v combine_kreports_kUnique.py
```

The Python generator also imports pandas. The local summarization needs MATLAB with table, join, and `groupsummary` support, BIOM, and a working QIIME 1 environment containing `summarize_taxa.py`. QIIME 2 is not a direct replacement for these commands. Check tool versions, compatible host/database formats, and available disk space before submission.

## 3 Generate SLURM job scripts

After removing automatic submission from the generator, run it from the pipeline root:

```bash
bash generate_slurm_all.sh
```

The generator discovers R1 files through links created from `fastq/*.fastq`, then writes one script per sample to each directory:

```text
Step1_Kneaddata/Kneaddata-SAMPLE_ID.sh
Step2_Kraken2_contig/Kneaddata-SAMPLE_ID.sh
Step3_Kraken2_unmapped/Kneaddata-SAMPLE_ID.sh
```

All three stages use the `Kneaddata-` filename prefix; the stage directory distinguishes them. Repeated generation overwrites those script filenames. Generate once for a new run, confirm that every R1 has a matching nonempty R2, and inspect existing outputs before regenerating or resubmitting.

## 4 Set permissions and inspect the jobs

```bash
chmod 750 Step1_Kneaddata/Kneaddata-*.sh
chmod 750 Step2_Kraken2_contig/Kneaddata-*.sh
chmod 750 Step3_Kraken2_unmapped/Kneaddata-*.sh
```

```text
grep -R '__[A-Z][A-Z_]*__' \
  Step1_Kneaddata Step2_Kraken2_contig Step3_Kraken2_unmapped
```

The placeholder check should return no output. Read one generated script from each stage. Confirm sample names, FASTQ paths, database paths, resource requests, and output paths. Check that job 1 generates the expected KneadData paired filenames before relying on those filenames in MEGAHIT and job 3. Keep a sample manifest and record submitted job IDs.

## 5 Submit host removal and assembly jobs

Submit from the stage directory because outputs in the templates are relative to the submission working directory. In a Bash shell:

```bash
cd Step1_Kneaddata
shopt -s nullglob
for job in Kneaddata-*.sh; do
  echo "Submitting $job"
  sbatch "$job"
done
cd ..
```

Do not repeat the loop for samples already running or completed. Job 1 uses paired cleaned reads for MEGAHIT; unpaired KneadData outputs are not included in this workflow.

Monitor and inspect completion:

```bash
squeue -u "$USER"
sacct -u "$USER" --starttime today \
  --format=JobID,JobName,State,ExitCode,Elapsed,MaxRSS
```

For each sample, confirm successful KneadData and MEGAHIT log entries and nonempty outputs:

```text
Step1_Kneaddata/kneaddata_output/
  SAMPLE_ID_R1_001_kneaddata_paired_1.fastq
  SAMPLE_ID_R1_001_kneaddata_paired_2.fastq
Step1_Kneaddata/megahit_output/SAMPLE_ID_out/
  SAMPLE_ID.contigs.fa
```

A completed SLURM job alone is insufficient with the original templates, because a failed intermediate command can be followed by a successful echo. If cleaned pairs or contigs are empty, investigate the sample rather than forcing the next stage to run.

## 6 Submit eligible contig and residual read jobs

Wait for job 1 to finish successfully for the relevant sample. From the pipeline root, run the following once for each downstream stage, changing `stage` as indicated:

```bash
stage=Step2_Kraken2_contig
# Then repeat with stage=Step3_Kraken2_unmapped
(
  cd "$stage" || exit 1
  shopt -s nullglob
  for job in Kneaddata-*.sh; do
    sample=${job#Kneaddata-}
    sample=${sample%.sh}
    pre=../Step1_Kneaddata
    clean="$pre/kneaddata_output/${sample}_R1_001_kneaddata"
    contigs="$pre/megahit_output/${sample}_out/${sample}.contigs.fa"
    if [[ -s "$contigs" && -s "${clean}_paired_1.fastq" && \
          -s "${clean}_paired_2.fastq" ]]; then
      echo "Eligible: $sample"
      sbatch "$job"
    else
      echo "Skipping $sample: missing preprocessing outputs"
    fi
  done
)
```

This checks inputs; it does not prevent duplicate submission or prove job 1 succeeded. Check the queue, logs, accounting, and existing outputs first. Jobs 2 and 3 may run concurrently after job 1. Collect only samples for which both downstream stages have succeeded.

Job 3 selects both-mapped pairs for contig counts and pairs with at least one unmapped mate for residual classification. Its current FASTQ extraction uses header matching with `grep`. Before a cohort run, replace that extraction with direct paired FASTQ export from the name-sorted BAM and verify equal record counts and matching mate identifiers. A suitable SAMtools command to validate on your installed version is:

```bash
samtools fastq -n \
  -1 Reads/Unmapped/SAMPLE_ID_R1_unmapped.fastq \
  -2 Reads/Unmapped/SAMPLE_ID_R2_unmapped.fastq \
  -0 /dev/null -s Reads/Unmapped/SAMPLE_ID_singletons.fastq \
  Reads/Unmapped/SAMPLE_ID_aln-unmapped_sorted.bam
```

Adapt this command to the sample placeholder in the template. Investigate any singleton records. If there are zero residual pairs, treat that as a valid zero-count branch and adapt the classification/combination code to retain the sample with zeros; do not silently omit it or classify an invalid empty input.

## 7 Verify the processing outputs

Expected key files for each sample are:

```text
Step2_Kraken2_contig/K2STD_result/report/
  kunique_SAMPLE_ID.report
Step2_Kraken2_contig/K2STD_result/output/
  kunique_SAMPLE_ID_contig_kraken_output.tsv
Step3_Kraken2_unmapped/
  krakenuniq_SAMPLE_ID_unmapped.report
  krakenuniq_SAMPLE_ID_unmapped.tsv
Step3_Kraken2_unmapped/Reads/Coverage/
  SAMPLE_ID_aln_coverage.txt
  SAMPLE_ID_mapped_flagstat.txt
  SAMPLE_ID_unmapped_flagstat.txt
  SAMPLE_ID_total_flagstat.txt
```

Check sample coverage across every file group, rather than accepting a wildcard collection of whichever files happen to exist. Compare mapped and residual alignment totals with the original cleaned pairs. Verify that coverage contig IDs match the KrakenUniq contig IDs. Confirm that reports are complete, use the same database, and refer to the intended samples.

## 8 Collect and download the key files

After applying the section 1 collection corrections and validating the custom combiner, run from the pipeline root:

```bash
bash Collect_files.sh
```

The core files needed for MATLAB are:

```text
core_files/
  kneaddata_read_count_table.tsv
  MegaHit_reports/Contig_STD.report
  Unmapped_reports/Unmapped_STD.report
  MegaHit_contig_Kraken2Output_STD/output/*.tsv
  Unmapped_Kraken2Output_STD/*.tsv
  Coverage_reads2contig/*_aln_coverage.txt
```

Inspect the two combined-report headers and confirm that their sample lists match the manifest. Archive this folder with checksums, software versions, database information, and job logs. Download it without moving the source cleaned reads needed for reruns.

On the local computer, use a fresh working folder containing sibling directories `core_files/` and `table_summarization/`. Copy only the MATLAB helpers and the summarization shell script into `table_summarization/`; do not copy the supplied example MAT, abundance, BIOM, or taxonomy output files into a new analysis.

## 9 Combine classifications in MATLAB

Start MATLAB with `table_summarization/` as the current folder. After uncommenting the three prerequisite processing blocks and fixing filename normalization, run:

```matlab
Step1_Main_SumWGScontigPip
```

This builds unmapped-pair and contig classification tables, joins contig classifications to SAMtools coverage counts, sums mapped reads by taxonomy ID, and merges mapped counts with twice the unmapped-pair counts. Its main outputs are:

```text
Assembly_pip/Unmapped/Assembly_pip_unmapped_Std_raw.txt
Assembly_pip/Mapped_contig/Assembly_pip_mapped_contig_Std_raw.txt
Assembly_pip/Mapped_read/Assembly_pip_mapped_read_Std_raw.txt
Assembly_pip/Combined_ready_table.txt
Assembly_pip/Combined_ready_table.mat
```

The combined table has taxonomy IDs in the first column, one numeric column per sample, and a final `taxonomy` column. The mapped-contig table is intermediate and must not be added as contig counts to the final read abundance table.

Before accepting the result, require unique normalized sample IDs and taxonomy IDs, identical sample sets between branches, finite nonnegative counts, and valid contig joins. Replace diagnostic `disp('Error!!!!!!!!')` messages with errors that stop processing. Check that every sample's combined total equals its retained mapped count plus twice its retained residual-pair count.

The current parser excludes unclassified and root records. Thus the combined table describes retained taxonomically assigned reads and does not necessarily sum to all cleaned reads. There is no explicit unique-k-mer confidence threshold, genome-length normalization, or cell-abundance correction in these scripts. Preserve host removal and mapping QC separately.

## 10 Reformat the taxonomy

The end of MATLAB step 1 already calls `fun_reorganize_shotgun_tax`. To make taxonomy reformatting a separate step, remove or comment out that final call and run the corrected step 2 function:

```matlab
Step2_main_reorganize_shotgun_tax
```

Both routes write:

```text
Assembly_pip/Combined_ready_table.txt.reformated.txt
```

The helper route writes `Assembly_pip/reformated_tax.txt`; the separate step 2 writes `reformated_tax.txt` in the current folder. These files compare original and reformatted taxonomy. The existing spelling `reformated` is retained because later commands expect it.

Verify that counts and sample columns are unchanged and taxonomy strings contain exactly eight positions. The supplied parser uses domain, kingdom, phylum, class, order, family, genus, and species. For Bacteria and Archaea it duplicates the domain at the kingdom position. Padding to the longest observed lineage is not sufficient when no eight-position lineage occurs; enforce eight positions explicitly before producing levels through 8.

## 11 Summarize the taxonomic levels

Run from `table_summarization/` in a shell initialized for Conda. Confirm that the environment named `qiime` provides QIIME 1 and BIOM:

```bash
conda activate qiime
command -v biom summarize_taxa.py
```

Before using `Step3_Summarize_tax_levels.sh`, ensure the BIOM input has a compatible observation-ID header. `writeResultTable.m` writes `OTU ID`; prepare the BIOM text header as `#OTU ID`, leaving sample names and taxonomy unchanged. Preserve the unmodified reformatted source as `wgs_table.raw.txt`. The existing shell script copies that source to both files, so replace its second copy with this header conversion:

```bash
cp Assembly_pip/Combined_ready_table.txt.reformated.txt \
  wgs_table.raw.txt
awk 'NR==1 {sub(/^OTU ID/, "#OTU ID")} {print}' \
  wgs_table.raw.txt > wgs_table.txt
```

Then run the script after correcting that copy step:

```bash
bash Step3_Summarize_tax_levels.sh
```

The script converts the table to `wgs_table.biom`, creates absolute read-count summaries in `tax_mapping_counts/`, and relative-abundance summaries in `tax_mapping_rel/`, for levels 2–8. In this eight-position convention, L2 is kingdom, L3 phylum, L4 class, L5 order, L6 family, L7 genus, and L8 species. Level numbers refer to positions in the lineage, not rank labels inferred by QIIME.

Verify BIOM conversion and inspect the generated tables. Absolute totals should be conserved at each level when all observations have complete lineage positions. Relative abundances should sum to approximately one per nonzero sample and reflect the taxa retained in the input table. These are fractions, not percentages. Handle zero-total samples explicitly.

The supplied shell script does not create `organized/` or rename summaries to filenames containing `reads_counts` or `relative_abundance`. Those additional files in the folder are existing results; any renaming or organization is a separate optional step.

## Handling failed jobs

Inspect SLURM and tool logs, correct the cause, and preserve partial outputs with a sample-specific `.failed.JOB_ID` name before rerunning. MEGAHIT may reject an existing output directory. Avoid deleting whole shared stage directories, which contain other samples' results. Rerun only the failed sample and required dependent stages. Recollect and rebuild local tables from the complete intended sample set afterward.

## Documentation and reproducibility

Record commands, software versions, input checksums, reference/database versions, sample manifest, job IDs, and all corrections used for the run. Tool references:

- [KrakenUniq documentation](https://github.com/fbreitwieser/krakenuniq)
- [SAMtools coverage and its numreads field](https://www.htslib.org/doc/samtools-coverage.html)
- [SAMtools paired FASTQ export](https://www.htslib.org/doc/samtools-fasta.html)
- [BIOM conversion and text headers](https://biom-format.org/documentation/biom_conversion.html)
- [Legacy QIIME source for taxonomic summaries](https://github.com/biocore/qiime/blob/master/scripts/summarize_taxa.py)

Cite the tools actually used in published analyses, including KneadData, MEGAHIT, KrakenUniq, Bowtie2, SAMtools, BIOM, and QIIME as applicable. Keep the database provenance separate from software citations.



# Useful Commands
## Check storage
```
iquota -p /panasas/scratch/grp-sunstar
```
## Unzip files
```
for x in ls *.gz;do gunzip $x;done
```

## Create symbolic link of files
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
##  Output mapping realtionship
```
mkdir mapping_list
for x in $(ls *_aln-mapped_sorted.bam);do samtools view $x | awk -F'\t' '{ print $1 "\t" $3 }' > mapping_list/$x.txt; done
```
