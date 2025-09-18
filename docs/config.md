# venae: General workflow settings

To configure this workflow, modify `nextflow.config` according to your needs or include additional configuration files, following the explanations provided in the file.

To see all possible parameter options, run `nextflow run main.nf --help`.

For a list of useful Nextflow general parameters, see [here](usage.md#nextflow-specific-arguments).

## Input/output parameters

A sample sheet is **required** for the pipeline to run. For each sample, columns `sample` and `reads` have to be defined. An example including the header row is shown below:

| sample   | reads                        |
| :------- | :--------------------------- |
| sample01 | path/to/sample01/reads.fastq |
| sample02 | path/to/sample02/reads.fastq |

The `sample` column is the sample identifier, and will be use to name output files and will be listed in the final report. The `reads` column is a path to the corresponding long-read fastq file for each sample. This file can be gzipped but it is not required. Other columns can be included but will not be processed.

The name of the sample sheet and directory can be changed by modifying the `samples` variable in the `nextflow.config` file or by specifying a custom commandline parameter `--samples <path to samplesheet>` or config file as described [here](usage.md#nextflow-specific-arguments). The default is `test/samples.tsv`

To specify the name of the output directory containing the output files, use `--outdir <folder name>`.

| Parameter   | Description                                                                                                                     | Type   | Default   | Notes                                                                                                                         |
| :---------- | :------------------------------------------------------------------------------------------------------------------------------ | :----- | :-------- | :---------------------------------------------------------------------------------------------------------------------------- |
| `--samples` | Path to comma-separated file containing information about the input samples                                                     | path   | null      |                                                                                                                               |
| `--outdir`  | The output directory where the output files will be saved                                                                       | path   | "results" |                                                                                                                               |
| `--email`   | "Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits. | string | null      | If set in your user config file (`~/.nextflow/config`) then you don't need to specify this on the command line for every run. |

## Report-specific parameters

To specify data processing thresholds, add the path to the fields in the **`Report-specific parameters`** section of the `nextflow.config` file or include the following on the command line.

| Parameter       | Description                              | Type   | Default  | Notes |
| :-------------- | :--------------------------------------- | :----- | :------- | :---- |
| `--report_name` | Name of output HTML report file          | string | "report" |       |
| `--timepoint`   | Timepoint to print in HTML report header | string | "3h"     |       |
| `--run_name`    | Run name to print in HTML report header  | string | "test"   |       |

## Data processing thresholds

To specify data processing thresholds, add the path to the fields in the **`Data processing thresholds`** section of the `nextflow.config` file or include the following on the command line.

| Parameter                           | Description                                                                                | Type    | Default | Notes |
| :---------------------------------- | :----------------------------------------------------------------------------------------- | :------ | :------ | :---- |
| `--spp_detection_percent_threshold` | Minimum percent sequence abundance for an organism to be reported in a sample              | float   | 2       |       |
| `--spp_min_number_reads_threshold`  | Minimum number of reads assigned to an organism for an organism to be reported in a sample | integer | 10      |       |
| `--min_read_qcore`                  | Minimum mean read Q-score for a sample to pass quality control                             | float   | 10      |       |
| `--min_median_read_length_bp`       | Minimum median read length for a sample to pass quality control                            | integer | 500     |       |

## Database-specific parameters

To specify pre-existing databases for tools, add the path to the fields in the **`Included assets/resources`** and the **`Databases`** sections of the `nextflow.config` file or include the following on the command line. By default, the databases will be stored in `assets/db_*`.

| Parameter                 | Description                                                                  | Type   | Default                                        | Notes                                                                            |
| :------------------------ | :--------------------------------------------------------------------------- | :----- | :--------------------------------------------- | :------------------------------------------------------------------------------- |
| `--pointfinder_orgs`      | StarAMR PointFinder database for antimicrobial resistance gene detection     | path   | "assets/pointfinder_organism.tsv"              | Included in this repository                                                      |
| `--emmtyper_db`           | emmtyper database for emm typing in Streptococcus pyogenes                   | path   | "assets/db_emmtyper/emm_types_20250131.fasta"  | Included in this repository                                                      |
| `--kmerresistance_db_arg` | KmerResistance ResFinder antimicrobial resistance database                   | string | "assets/db_kmerresistance/resfinder_v2.4.0"    | Included in this repository                                                      |
| `--kmerresistance_db_spp` | KmerResistance KMA species placeholder database                              | string | "assets/db_kmerresistance/species_placeholder" | Included in this repository                                                      |
| `--genomesize_key`        | Key file with average genome size for each bacterial/fungal genus in NCBI    | path   | "assets/ncbi_genus_size.tsv"                   | Included in this repository                                                      |
| `--cge_key`               | CGE phenotype key file for KmerResistance antimicrobial resistance detection | path   | "assets/cge_key_20240612_phenotypes.txt"       | Included in this repository                                                      |
| `--clsi_key`              | CLSI organism key file for reportable antimicrobial phenotype                | path   | "assets/clsi_key.txt"                          | Included in this repository                                                      |
| `--timepoint`             | CLSI Table references for reportable antimicrobial phenotypes                | path   | "assets/Table1\*.txt"                          | Included in this repository                                                      |
| `--nohuman_db`            | NoHuman database for host read removal                                       | path   | null                                           | Must be downloaded separately, see [here](installation.md#database-installation) |
| `--checkm2_db`            | CheckM2 database to assess assembly completeness                             | path   | null                                           | Must be downloaded separately, see [here](installation.md#database-installation) |
| `--kraken2_db`            | Kraken2 database for species identification                                  | path   | null                                           | Must be downloaded separately, see [here](installation.md#database-installation) |
| `--sylph_db_bac`          | Sylph database for bacterial identification                                  | path   | null                                           | Must be downloaded separately, see [here](installation.md#database-installation) |
| `--sylph_db_fungi`        | Sylph database for fungal identification                                     | path   | null                                           | Must be downloaded separately, see [here](installation.md#database-installation) |
| `--sylph_tax_bac`         | Sylph-tax database to assign bacterial taxonomy                              | path   | null                                           | Must be downloaded separately, see [here](installation.md#database-installation) |
| `--sylph_tax_fungi`       | Sylph-tax database to assign fungal taxonomy                                 | path   | null                                           | Must be downloaded separately, see [here](installation.md#database-installation) |

## Tool-specific parameters

To specify pre-existing databases for tools, add the path to the fields in the **`Tool-specific parameters`** section of the `nextflow.config` file or include the following on the command line.

| Parameter                         | Description                                                                                                       | Type    | Default     | Notes                                                                                                                       |
| :-------------------------------- | :---------------------------------------------------------------------------------------------------------------- | :------ | :---------- | :-------------------------------------------------------------------------------------------------------------------------- |
| `--flye_mode`                     | Flye mode depending on the input data (source and error rate) (options: "--nano-hq", "--nano-raw", "--nano-corr") | string  | "--nano-hq" | See description of tool parameters [here](https://github.com/mikolmogorov/Flye/blob/flye/docs/USAGE.md#inputdata)           |
| `--kraken2_save_output_fastqs`    | Save classified and unclassified reads as fastq files from Kraken2                                                | boolean | false       | See description of tool parameters [here](https://github.com/DerrickWood/kraken2/blob/master/docs/MANUAL.markdown#classify) |
| `--kraken2_save_reads_assignment` | Save a file reporting the taxonomic classification of each input read from Kraken2                                | boolean | false       | See description of tool parameters [here](https://github.com/DerrickWood/kraken2/blob/master/docs/MANUAL.markdown#classify) |
| `--abricate_databasedir`          | Path to ABRicate database directory if different from default                                                     | string  | null        |                                                                                                                             |

## Custom configuration

### Resource labels

The following default resource labels found in `base.config` can be adjusted in a custom config file:

- `process_quick`: 1 cpus, 2GB memory, 10 mins
- `process_single` (nf-core label): 1 cpus, 4GB memory, 4 hours
- `process_medium` (nf-core label): 4 cpus, 24GB memory, 8 hours
- `process_cpus`: 8 cpus, 6GB memory, 4 hours

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customise the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the pipeline steps, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher resources request (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.

### Custom Containers

In some cases, you may wish to change the container or conda environment used by a pipeline steps for a particular tool. By default, nf-core pipelines use containers and software from the [biocontainers](https://biocontainers.pro/) or [bioconda](https://bioconda.github.io/) projects. However, in some cases the pipeline specified version maybe out of date.

To use a different container from the default container or conda environment specified in a pipeline, please see the [updating tool versions](https://nf-co.re/docs/usage/configuration#updating-tool-versions) section of the nf-core website.

### Custom Tool Arguments

A pipeline might not always support every possible argument or option of a particular tool used in pipeline. Fortunately, nf-core pipelines provide some freedom to users to insert additional parameters that the pipeline does not include by default.

To learn how to provide additional arguments to a particular tool of the pipeline, please see the [customising tool arguments](https://nf-co.re/docs/usage/configuration#customising-tool-arguments) section of the nf-core website.

## Documentation

- [Installation](installation.md)
- [Configuration](config.md)
- [Usage](usage.md)
- [Output](output.md)
- [Tools](tools.md)
- [Citations](../CITATIONS.md)
