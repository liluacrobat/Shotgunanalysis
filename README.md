# Shotgunanalysis

## Merge reports from Kraken2
download files and process with Matlab

```
eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/kraken2
export PATH=$PATH:/projects/academic/pidiazmo/projectsoftwares/KrakenTools
combine_kreports.py -r report/*.report -o Combined_std.report
cd uclassified/sh
combine_kreports.py -r report/*.report -o Combined_NIH.report
```
