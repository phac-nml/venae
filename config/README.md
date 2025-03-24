# General workflow settings

To configure this workflow, modify `config/config.yaml` according to your needs, following the explanations provided in the file.

## Sample sheet

A sample sheet is required for the pipeline folder. For each sample, columns `sample` and `reads` have to be defined. An example including the header row is shown below:

| sample |  reads |
| :--- | :--- |
| sample01 | path/to/sample01/reads.fastq |
| sample02 |  path/to/sample02/reads.fastq |

The `sample` column is the sample identifier, and will be use to name output files and will be listed in the final report. The `reads` column is a path to the corresponding long-read fastq file for each sample. This file can be gzipped but it is not required. 

The name of the sample sheet and directory can be changed by modifying the `SAMPLES` variable in the `config/config.yaml` file. The default is `config/samples.tsv`

## Results output folder and report names

The name of the output results folder can be changed by modifying the `OUTPUT_FOLDER_NAME` variable in the `config/config.yaml` file. The default is `results`.

The name of the final output report can be change by modifying the `OUTPUT_REPORT_NAME` variable in the `config/config.yaml` file. The default is `report`.

## Tool-specific parameters 

To adjust specific parameters used by tools in the workflow, edit the fields in the **`PARAMS`** section of the `config.yaml`:

- NOHUMAN (host removal):
    - verbose `-v`
- NANOQ_SPP (NanoQ read filtering for species detection):
    - minimum read length `-l 2000`
    - minimum read quality `-q 10` 
- NANOQ_ASSEMBLY (NanoQ read filtering for assembly): 
    - minimum read length ` -l 1000`
    - minimum read Q-score ` -q 10`
- NANOPLOTFORMAT (Nanoplot read input format for qc reports):
    - FASTQ format `--fastq`
- NANOPLOT (Nanoplot read quality report metrics): 
    - log-transform plot scales ` --loglength`
    - do not make static plots ` --no_static`
- KRAKEN2 (Kraken2 early species identification tool):
    - print human readable taxonomy names ` --use-names`
- SYLPH_SKETCH (Sylph species identification):
    - compression parameter `-c 200`
- SYLPH_PROFILE (Sylph species identification):
    - include percentage of unknown reads `-u`
- SYLPH_TAX (Sylph species identification taxonomy assignment)
- FLYE (Flye assembly parameters):
    - include the meta flag ` --meta`
    - include high-quality ONT/Nanopore data ` --nano-hq`
- CHECKM2 (CheckM2 to assess assembly completeness): 
    - specify assembly file extensions ` -x fasta`
    - delete intermediate files ` --remove_intermediates`
    - force overwrite of exising files on re-run ` --force`
- COVERM (CoverM to compute assembly coverage metrics): 
    - metrics to evaluate ` mean length`
    - additional metric required to compute length ` --min-covered-fraction 0`
- STARAMR (StarAMR for AMR detection):
    - percent identity ` --pid-threshold 90`
- KMERRESISTANCE
    - ONT long-read preset for KMA `-ont`
- QUAST (QUAST assembly quality metrics):
    - minimum size of contig considered ` --min-contig 0`
- STAPH_AUREUS_TYPING (*Staphylococcus aureus* toxin typing via VFDB and ABRicate)
- STREP_PYOGENES_TYPING (*Streptococcus pyogenes* *emm* typing via emmtyper)
    - verbose `--output format verbose`


## Report-specific parameters 

To adjust specific parameters output in the final HTML report, edit the fields in the **`REPORT`** section of the `config.yaml`:

- SPP_DETECTION_PERCENT_THRESHOLD (minimum percent sequence abundance for an organism to be reported in a sample):
    - default: ` 5`
- SPP_MIN_NUM_READS_THRESHOLD (minimum number of reads assigned to an organism for an organism to be reported in a sample): 
    - default: ` 10`
- MIN_READ_QSCORE (minimum mean read Q-score for a sample to pass quality control): 
    - default: ` 10`
- MIN_MEDIAN_READ_LENGTH_BP (minimum median read length for a sample to pass quality control): 
    - default: ` 500`
- TIMEPOINT (timepoint of sampling evaluated): 
    - `3h`
- RUNNAME (custom run name or date): 
    - `20231220`

## Database-specific parameters 

To specify pre-existing databases for tools, add the path to the fields in the **`DATABASES`** section of the `config.yaml`. By default, the databases will be stored in `resources/db_*`.

- NOHUMAN_DB (NoHuman human index for human read removal):
    - default: Kraken2 index of the Human Pangenome Reference Consortium's first human pangenome
- KRAKEN2_DB (Kraken2 database used for species identification):
    - default: PlusPF 16Gb 
- CHECKM2_DB (CheckM2 database for assembly completeness):
    - default: `uniref100.KO.1.dmnd`
- KMERRESISTANCE_DB_ARG (KmerResistance database prefix for AMR detection): 
    - default: custom indexed ResFinder database 
- KMERRESISTANCE_DB_SPP (KmerResistance database prefix for species identification): 
    - default: placeholder database with a single *Staphylococcus aureus* isolate
- SYLPH_DB_BAC (Sylph database for bacteria identification): 
    - default: `gtdb-r220-c200-dbv1.syldb`
- SYLPH_DB_FUNGI (Sylph database for fungi identification): 
    - default: `fungi-refseq-2024-07-25-c200-v0.3.syldb`
- SYLPH_TAX_BAC (Sylph bacteria taxonomy classification): 
    - default: `gtdb_r220_metadata.tsv.gz`
- SYLPH_TAX_FUNGI (Sylph fungi taxonomy classification): 
    - default: `fungi_refseq_2024-07-25_metadata.tsv.gz`
- EMMTYPER_DB (Emmtyper database prefix for Streptococcus pyogenes* *emm* types):
    - default: CDC *emm* database
