## Installation

> :warning: This pipeline has run exclusively on Linux machines and has not been tested on other operating systems.

Installation requires [Nextflow](https://www.nextflow.io/) (minimum version tested 24.04.4) and the [conda](https://docs.conda.io/en/latest/miniconda.html) dependency management system to run. In addition, this workflow depends on several external databases which should be downloaded prior to initially running the pipeline.

For more information on how to install conda, see the [miniforge](https://github.com/conda-forge/miniforge) or [miniconda](https://docs.conda.io/en/latest/miniconda.html) documentation. Once conda is installed, ensure the following channels are added:

```bash
conda config --add channels bioconda
conda config --add channels conda-forge
```

## Download and install Nextflow

The Nextflow environment can be installed via conda:

`conda create -n nextflow -c bioconda -c conda-forge nextflow`

## Clone this repository

Run this command to copy this repository to obtain the scripts:

`git clone https://<pipeline repository path>.git`

## Database installation

This workflow currently depends on external databases for the following tools:

- NoHuman (5 Gb)
- Kraken2 (8 Gb)
- CheckM2 (3 Gb)
- sylph (16 Gb)
- sylph taxonomy (14 Mb)
- KmerResistance comprising ResFinder (9 Mb) and KmerFinder (16 Mb) (both included in this repository)
- emmtyper (2 Mb, included in this repository)

A script `bin/download_databases.sh` has been included and can be run after cloning the repository in the working directory with the following Bash command:

```bash
bash bin/download_databases.sh
```

This script will take a few minutes to run and will install the first five databases listed above in respective `assets/db_*` folders.

Alternatively, pre-existing databases can be used as long as their respective paths are updated in the `nextflow.config` file. See [here](../config/README.md#database-specific-parameters-databases) for more information.

## Updating exising databases

For more information on how to update databases included in the `bin/download_databases.sh` script, refer to the instructions for each tool [listed here](tools.md#included-tools).

Databases for two tools (KmerRessistance and emmtyper) are small in size and are included in this repository in the following folders:

- `assets/db_kmerresistance/`
- `assets/db_emmtyper/`

To update these databases manually, see the steps below.

### KmerResistance

The KmerResistance tool created by the Centre for Genomic Epidemiology (CGE) performs both species identification and antimicrobial resistance identification using long reads. CGE recommends using the databases from their other tools [KmerFinder](https://bitbucket.org/genomicepidemiology/kmerfinder_db/src/master/) for species ID and [ResFinder](https://bitbucket.org/genomicepidemiology/resfinder_db/src/master/) for antimicrobial resistance detection.

There are several issues with the KmerFinder database. The bacteria database is large (35 Gb) and is loaded into memory when running which requires significant computational resources. Currently, there is no pre-built database that includes both bacteria and fungi (must be custom made). Furthermore, this tool is unable to identify multiple organisms in a single sample. Given that species identification is perfomred more reliably with other tools using smaller databases ([sylph and Kraken2](tools.md#species-identification)), this pipeline uses a dummy placeholder species database in place of the full KmerFinder database.

This dummy/placeholder database comprises one _Staphylococcus aureus_ NCTC 8325 reference isolate with the [RefSeq assembly GCF_000013425.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000013425.1/). To build this database, run the following Bash commands: (note that **KMA** >= v1.4.0 is required to index these databases)

```bash
# Download and unzip the assembly file
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz
gunzip GCF_000013425.1_ASM1342v1_genomic.fna.gz

# Index the assembly file with KMA
kma index -i GCF_000013425.1_ASM1342v1_genomic.fna -Sparse ATG -o species_placeholder

# Move the indexed files to the database directory and remove the downloaded file
mv species_placeholder* assets/db_kmerresistance/
rm GCF_000013425.1_ASM1342v1_genomic.fna
```

The same steps above can be repeated to create a custom species database with any number of genomes if desired. The full KmerFinder database can be found at the following links:

- https://cge.food.dtu.dk/services/KmerFinder/etc/kmerfinder_db.tar.gz
- ftp://ftp.cbs.dtu.dk/public/CGE/databases/KmerFinder/version/latest/bacteria\*
- ftp://ftp.cbs.dtu.dk/public/CGE/databases/KmerFinder/version/latest/fungi\*

If creating a custom database or if using the full KmerFinder database, ensure the path to this database is updated in the `nextflow.config` file if stored elsewhere than the default:

```yaml
DATABASES: kmerresistance_db_arg = "assets/db_kmerresistance/resfinder_v2.4.0"
  kmerresistance_db_spp = "assets/db_kmerresistance/species_placeholder"
```

To update the ResFinder database for antimicrobial resistance detection, run the following Bash commands: (note that **KMA** >= v1.4.0 is required to index these databases, and the `-m 14` flag is included to apply minimizers as recommended [here](https://bitbucket.org/genomicepidemiology/kmerresistance/issues/2/ont-long-reads-as-input-for-kmerresistance) for ONT data)

```bash
# Download the database file
wget https://bitbucket.org/genomicepidemiology/resfinder_db/raw/HEAD/all.fsa

# Index the database file
kma index -i all.fsa -m 14 -o resfinder_v2.4.0

# Move the indexed files to the database directory and remove the downloaded file
mv resfinder_v2.4.0* assets/db_kmerresistance/
rm all.fsa
```

### emmtyper

emmtyper runs _emm_ typing on _Streptococcus pyogenes_ isolates and is based on the U.S. Centers for Disease Control and Prevention's database found [here](https://ftp.cdc.gov/pub/infectious_diseases/biotech/emmsequ/). This database has been included in the `assets/db_emmtyper/` folder.

To update the emmtyper database, run the following Bash commands from the working directory (note that **BLAST** is required to build this database):

```bash
# Download the database file
wget https://ftp.cdc.gov/pub/infectious_diseases/biotech/tsemm/alltrimmed.tfa -N -P assets/db_emmtyper

# Get the date of the database file
DATE=$(date -r assets/db_emmtyper/alltrimmed.tfa "+%Y%m%d")

# Pull out the emm sequences
awk -v RS="\n>" -v FS="\n" '$1 ~ /EMM/ {print ">"$0}' assets/db_emmtyper/alltrimmed.tfa | sed 's#>>#>#' > emm_types_${DATE}.fasta

# Make blast database
makeblastdb -in emm_types_${DATE}.fasta -dbtype nucl

# Move the indexed files to the database directory and remove the downloaded file
mv emm_types_*.fasta* assets/db_emmtyper/
rm assets/db_emmtyper/alltrimmed.tfa
```

If using a pre-existing database, ensure the path to this database is updated in the `nextflow.config` file if stored elsewhere than the default:

```yaml
emmtyper_db = "assets/db_emmtyper/emm_types_20250131.fasta"
```

## Documentation

- [Installation](installation.md)
- [Configuration](config.md)
- [Usage](usage.md)
- [Output](output.md)
- [Tools](tools.md)
- [Citations](../CITATIONS.md)
