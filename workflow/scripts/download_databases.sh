# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
#
# PURPOSE: 
# This script will download the larger databases used for the 
# venae pipeline. It will automatically stored the databases 
# in the resources/ folder in # subfolders named db_*
# AUTHOR: Nicole Lerminiaux <nicole.lerminiaux@phac-aspc.gc.ca>
#
# COMMAND LINE USAGE:
#
# bash scripts/download_databases.sh
#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

#!/bin/bash

echo ""
echo "*********************"
echo "Gathering inputs..."
echo "*********************"
echo ""

INSTALL_DIR=$(echo "$(pwd)/resources")

if [ ! -d "${INSTALL_DIR}" ]; then
  echo "${INSTALL_DIR} does not exist. Please edit this installation directory in this script to point to a directory that exists (default: resources)"
  exit 1
else
    echo "Will install databases in the following directory: ${INSTALL_DIR}"
    echo ""
fi

# download NoHuman db ~5 Gb
echo ""
echo "*********************"
echo "Downloading NoHuman database..."
echo "*********************"
echo ""

mkdir ${INSTALL_DIR}/db_nohuman

wget https://zenodo.org/records/8339732/files/k2_HPRC_20230810.tar.gz -nv

echo ""
echo "*********************"
echo "Downloaded. Opening..."
echo "*********************"
echo ""

tar -xvzf k2_HPRC_20230810.tar.gz -C ${INSTALL_DIR}/db_nohuman

rm k2_HPRC_20230810.tar.gz

echo ""
echo "*********************"
echo "Done"
echo "*********************"
echo ""

# download Kraken2 db ~9 Gb
echo ""
echo "*********************"
echo "Downloading Kraken2 database..."
echo "*********************"
echo ""

mkdir ${INSTALL_DIR}/db_k2_pluspf_08gb_20241228

wget https://genome-idx.s3.amazonaws.com/kraken/k2_pluspf_08gb_20241228.tar.gz -nv

echo ""
echo "*********************"
echo "Downloaded. Opening..."
echo "*********************"
echo ""

tar -xvzf k2_pluspf_08gb_20241228.tar.gz -C ${INSTALL_DIR}/db_k2_pluspf_08gb_20241228

rm k2_pluspf_08gb_20241228.tar.gz

echo ""
echo "*********************"
echo "Done"
echo "*********************"
echo ""

# download CheckM2 db ~3 Gb 
echo ""
echo "*********************"
echo "Downloading CheckM2 database..."
echo "*********************"
echo ""

mkdir ${INSTALL_DIR}/db_checkm2

wget https://zenodo.org/records/5571251/files/checkm2_database.tar.gz -nv

echo ""
echo "*********************"
echo "Downloaded. Opening..."
echo "*********************"
echo ""

tar -xvzf checkm2_database.tar.gz -C ${INSTALL_DIR}/db_checkm2

rm checkm2_database.tar.gz

echo ""
echo "*********************"
echo "Done"
echo "*********************"
echo ""

# download Sylph db ~ 16 Gb
echo ""
echo "*********************"
echo "Downloading Sylph databases..."
echo "*********************"
echo ""

wget http://faust.compbio.cs.cmu.edu/sylph-stuff/gtdb-r220-c200-dbv1.syldb -N -P ${INSTALL_DIR}/db_sylph -nv

wget http://faust.compbio.cs.cmu.edu/sylph-stuff/fungi-refseq-2024-07-25-c200-v0.3.syldb -N -P ${INSTALL_DIR}/db_sylph -nv

echo ""
echo "*********************"
echo "Done"
echo "*********************"
echo ""

# download Sylph taxonomy ~ 14 Mb
echo ""
echo "*********************"
echo "Downloading Sylph taxonomy files..."
echo "*********************"
echo ""

wget https://zenodo.org/records/14320496/files/gtdb_r220_metadata.tsv.gz -N -P ${INSTALL_DIR}/db_sylph-tax -nv

wget https://zenodo.org/records/14320496/files/fungi_refseq_2024-07-25_metadata.tsv.gz -N -P ${INSTALL_DIR}/db_sylph-tax -nv

echo ""
echo "*********************"
echo "Done"
echo "*********************"
echo ""
echo "*********************"
echo "All databases are downloaded!"
echo ""
echo "Downloaded databases can be found here:"
echo ""
echo ""
echo "NoHuman: ${INSTALL_DIR}/db_nohuman"
echo "Kraken2: ${INSTALL_DIR}/db_k2_pluspf_16gb"
echo "CheckM2: ${INSTALL_DIR}/db_checkm2"
echo "Sylph: ${INSTALL_DIR}/db_sylph"
echo "Sylph-tax: ${INSTALL_DIR}/db_sylph-tax"
echo "*********************"


