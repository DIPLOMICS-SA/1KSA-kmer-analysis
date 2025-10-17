#!/bin/bash
set -e

# Define container
CONTAINER_PATH="/path/to/1ksa_kmer.sif"   # <-- change this to where your .sif is
KMER=17

# Check if input file and species name are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <input_file> <genus_species>"
    exit 1
fi

FILE=$1
SPECIES=$2

# Compute total bases (outside container is fine)
echo "${FILE}" > total_number_bases.txt
cat "${FILE}" | awk 'NR%4==2 {sum+=length($0)} END {print sum}' >> total_number_bases.txt &

# Run KMC and KMC_tools inside the container
apptainer exec "$CONTAINER_PATH" bash -c "
    kmc -cs1000 -m24 -sm -ci3 -k${KMER} -fq -t7 ${FILE} ${SPECIES}_${KMER}_mers . &&
    kmc_tools transform ${SPECIES}_${KMER}_mers histogram ${SPECIES}_${KMER}_mers_histo.txt
"

wait

# Run the R script for plotting
Rscript kmerPlot.R
