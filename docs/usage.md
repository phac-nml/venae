## Usage

This page includes a description of input files and instructions on how to run the **venae** pipeline. 

## Index

- [Quick start](#quick-start)
- [Input files and sample sheet](#input-files-and-sample-sheet)
- [Profiles](#profiles)
- [Config file](#config-file)
- [Running the test dataset](#running-the-test-dataset)
- [Snakemake-specific arguments](#snakemake-specific-arguments)
- [Running with snk](#running-with-snk)

## Quick start

To start the workflow with the test dataset, ensure Snakemake is accessible and run the following command from the cloned repository:

```bash
snakemake --profile <PROFILE> --cores <JOBS>
```

where:
- `--profile <PROFILE>`: the Snakemake profile to use, which includes specifying the conda dependency management system
- `--cores <JOBS>`: the number of jobs that will run concurrently

This will begin the pipeline using the `config/samples.tsv` file to specify the sample names and paths to two samples in the `test/` folder.

## Input files and sample sheet

**venae** uses a sample sheet as input. The sample sheet is found in `config/samples.tsv` and should look like this: 

| sample |  reads |
| :--- | :--- |
| sample01 | path/to/sample01/reads.fastq |
| sample02 |  path/to/sample02/reads.fastq |

The `sample` column is the sample identifier, and will be use to name output files and will be listed in the final report. The `reads` column is a path to the corresponding long-read fastq file for each sample. This file can be gzipped but it is not required. If you have multiple reads associated with one sample, please concatenate them and provide the path to the concatenated read set.

If you already have reads named `SAMPLE_minion.fastq.gz` in a folder called `nanopore_reads`, you can run the following to quickly generate a sample sheet:

`find nanopore_reads -type f | sed 's#nanopore_reads/##g;s#_minion.fastq.gz##g' | sort | sed 's#\(.*\)#\1\tnanopore_reads/\1_minion.fastq.gz#' | sed -e '1i\sample\treads' > config/samples.tsv`

## Profiles

Snakemake can accept profiles for running on high-performance computing clusters. See [the Snakemake documentation](https://snakemake.readthedocs.io/en/stable/executing/cli.html#profiles) for more information. 

## Config file

A configuration file `config.yaml` has been included in `config/` folder which specifies tool parameters and paths to databases. See [here](../config/README.md) for more information on how to configure this file. 

## Running the test dataset

Included with this pipeline are two read sets in the `test/` folder that can be used to test the pipeline. These include publicly available ONT reads from open-access papers:
- *Streptococcus pyogenes* (SRR22957083, isolate 221221SPYBC52) from a 2022 outbreak in London, United Kingdom by [Alcolea-Medina *et al.* 2023](https://doi.org/10.1016/j.cmi.2023.03.001)
- *Escherichia coli* (SRR26162843, isolate IsolateD) from a 2023 validation of ONT sequencing for carbapenemase-producing organisms by [Lerminiaux *et al.* 2024](https://doi.org/10.1139/cjm-2023-0175) 

These read sets were subsampled using [rasusa v2.0.0](https://github.com/mbhall88/rasusa) to obtain approximately 12-fold coverage (*S. pyogenes*) and 7-fold coverage (*E. coli*). Simulated human reads derived from the reference human genome GRCh38.p14 assembly in GenBank [GCA_000001405.29](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_000001405.29/) were obtained with [NanoSim v3.2.3](https://github.com/bcgsc/NanoSim) using the `human_giab_hg002_sub1M_kitv14_dorado_v3.2.1` pre-trained model. Human reads were concatenated with the subsampled isolate reads (n=1000 human reads for *S. pyogenes*, n=600 reads for *E. coli*). 

To run the test dataset, the existing `config/samples.tsv` file is already configured for the test dataset:

| sample |  reads |
| :--- | :--- |
| SRR22957083 | test/SRR22957083_subset_withhuman.fastq.gz |
| SRR26162843 |  test/SRR26162843_subset_withhuman.fastq.gz |

Start the workflow as normal:

```bash
snakemake --profile <PROFILE> --cores <JOBS>
```

The output `report.html` will show example results for both isolates, and should match the example report in `test/report.html`.

## Snakemake-specific arguments

A list of all Snakemake arguments can be found [here](https://snakemake.readthedocs.io/en/stable/executing/cli.html) or listed with `snakemake --help`, but several useful ones are included below.

**`-np`**

Specify this option for Snakemake to print a dry run (`-n`) along with shell commands to be excuted (`-p`).

**`--unlock`**

Include this argument if the Snakemake directive was killed while running and the directory is locked. This will quickly unlock the working directory, and then the pipeline can be resumed with the standard command. 

**`--rerun-incomplete`**

Include this argument if the Snakemake directive was killed by the cluster and jobs were started but not completed. This option is also useful if there is incomplete Snakemake metadata. 

**`--conda-prefix <PATH>`**

Specify a directory for conda environments and their archives. If the same path is specified over multiple workflow folders and the environments haven't changed, it will continue to use the same environment and will skip creating environments each time the workflow is run. 

**`--default-resources "<RESOURCE>=<VALUE>"`**

Specify resources used by the workflow. Useful for clusters that require resource specifications for all jobs for submission, i.e. `--default-resources "runtime='10m'"`to specify a maximum runtime of 10 minutes for each rule.

**`--configfile`**

Specify or overwrite the existing `config/config.yaml` file with another. 

**`--config`** 

Set or overwrite specific config values in the workflow. For example, `--config samples="more_samples.tsv"` will overwrite `samples.tsv` specific in `config/config.yaml` with a different file. 

**`--delete-temp-output`** 

The `results/` folder contains mostly text files and consequently it does not have a large space footprint. The exceptions are the filtered read sets used for assembly and species identification. Use this flag to remove those files to use less disk space. Can be used in combination with `-n` to see the list of files that will be deleted. Upon re-running the workflow, these files will be regenerated. 

## Running with snk

[`Snk`](https://github.com/Wytamma/snk) is a Snakemake workflow management system that can be used to run **venae**. See the [snk documentation here](https://snk.wytamma.com/) for installing snk in a conda environment. Once `snk` installed and activated, this pipeline can be installed with:

```bash
snk install <URL of pipeline> -d snakemake-executor-plugin-slurm -d snakemake-executor-plugin-cluster-generic -d pandas==2.2.3 --force

# To view installed workflows
snk --list
```

`snk` creates its own .yaml config file. For edits to this file, or to edit the pipeline config file for database paths or other parameters, run the following: 

```bash
# Print the path to where the workflow is stored
snk edit --path venae
# For editing snk parameters
nano <path>/venae/snk.yaml
# For editing workflow config file
nano <path>/venae/config/config.yaml 
```

Navigate to any folder to run this pipeline with `snk`:

```bash
venae run --samples samples.tsv --cores 16 --profile slurm -r workflow/ -r .here
```

where:
- `--profile <PROFILE>`: the Snakemake profile to use, which includes specifying the conda dependency management system
- `--cores <JOBS>`: the number of jobs that will run concurrently
- `--samples samples.tsv`: the [sample sheet](#input-files-and-sample-sheet) specifying sample names and paths to input reads
- `-r workflow/ -r .here`: specify that `workflow/` and `.here` are required files so they will be copied to the working directory. Note that the `resources/` folder is automatically copied to the working directory. 

**NOTE**: this example with `snk` was tested with `snk` v0.31.1. 

## Documentation

- [Installation](installation.md)
- [Configuration](../config/README.md)
- [Usage](usage.md)
- [Output](output.md)
- [Tools](tools.md)
- [Citations](../CITATIONS.md)
