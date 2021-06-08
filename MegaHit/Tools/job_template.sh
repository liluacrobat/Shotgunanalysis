#!/bin/sh
#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="M-__SAMPLE_ID__"
#SBATCH --output=M-__SAMPLE_ID__.log

module load megahit
# Replace DWK to the directory of kneaddata_output
DWK='/panfs/panfs.cbls.ccr.buffalo.edu/scratch/grp-pidiazmo/NIH_shotgun/NIH/kneaddata/sh/NIH_result_summary/kneaddata_output'

echo '--------------------'
echo 'Start ...'

megahit -1 $DWK/__SAMPLE_ID___R1_kneaddata_paired_1.fastq -2 $DWK/__SAMPLE_ID___R1_kneaddata_paired_2.fastq -o __SAMPLE_ID___out  --out-prefix __SAMPLE_ID__

echo 'End'
echo '--------------------'
