#!/bin/sh
chmod 777 *.sh
for f in $(ls *.sh);do sbatch $f;done
