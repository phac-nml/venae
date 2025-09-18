# venae: Usage

This page includes a description of input files and instructions on how to run the **venae** pipeline.

## Index

- [Quick start](#quick-start)
- [Samplesheet input](#samplesheet-input)
- [Profiles](#profiles)
- [Config file](#config-file)
- [Running the pipeline](#running-the-pipeline)
- [Running the test dataset](#running-the-test-dataset)
- [Core Nextflow arguments](#core-nextflow-arguments)
- [Running with snk](#running-with-snk)

## Quick start

To start the workflow with the test dataset, ensure Nextflow is accessible and run the following command from the cloned repository:

```bash
nextflow run main.nf \
   -profile <PROFILE> \
   --input <PATH/TO/SAMPLESHEET.tsv> \
   --outdir <OUTDIR>
```

where:

- `-profile <PROFILE>`: the Nextflow profile to use, which includes specifying the dependency management system (conda, singularity)
- `--input <PATH/TO/SAMPLESHEET.tsv>`: Path to a TSV file with column headers `sample` and `reads`, see example [here]()
  - `sample`: name of the sample which will be printed in all results
  - `reads`: path to the long-read .fastq/.fq/fastq.gz/fq.gz file
- `--outdir <OUTDIR>`: name of the output folder containing the results

## Samplesheet input

**venae** uses a sample sheet as input. An example sample sheet is found in `test/samples.tsv` and should look like this:

| sample   | reads                        |
| :------- | :--------------------------- |
| sample01 | path/to/sample01/reads.fastq |
| sample02 | path/to/sample02/reads.fastq |

The `sample` column is the sample identifier, and will be use to name output files and will be listed in the final report. The `reads` column is a path to the corresponding long-read fastq file for each sample. This file can be gzipped but it is not required. If you have multiple reads associated with one sample, please concatenate them and provide the path to the concatenated read set.

If you already have reads named `SAMPLE_minion.fastq.gz` in a folder called `nanopore_reads`, you can run the following to quickly generate a sample sheet:

`find nanopore_reads -type f | sed 's#nanopore_reads/##g;s#_minion.fastq.gz##g' | sort | sed 's#\(.*\)#\1\tnanopore_reads/\1_minion.fastq.gz#' | sed -e '1i\sample\treads' > samples.tsv`

## Profiles

Profiles are used to specify dependency installation, resources, and how to handle pipeline jobs. You can specify more than one profile with `-profile <PROFILE1>,<PROFILE2>`.

Available profiles:

- conda: Use conda to install dependencies and manage environments
- singularity: Use singularity to install dependencies and manage environments

Other profiles:

- test: Run pipeline with test dataset
- nml: Use NML-specific configuration files for urnning on slurm HPC
- clean: Run pipeline with `-cleanup` set to TRUE

## Config file

See [here](config.md) for more information on how to configure this pipeline.

## Running the test dataset

The typical command for running the pipeline is as follows:

```bash
nextflow run main.nf --input samplesheet.csv --outdir results -profile singularity
```

This will launch the pipeline with the `singularity` configuration profile. See above for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

If you wish to repeatedly use the same parameters for multiple runs, rather than specifying each flag in the command, you can specify these in a params file.

Pipeline settings can be provided in a `yaml` or `json` file via `-params-file <file>`.

> [!WARNING]
> Do not use `-c <file>` to specify parameters as this will result in errors. Custom config files specified with `-c` must only be used for [tuning process resource specifications](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources), other infrastructural tweaks (such as output directories), or module arguments (args).

The above pipeline run specified with a params file in yaml format:

```bash
nextflow run phac-nml/venae -profile singularity -params-file params.yaml
```

with:

```yaml title="params.yaml"
input: 'samplesheet.csv'
outdir: 'results'
<...>
```

## Running the test dataset

Included with this pipeline are two read sets in the `test/` folder that can be used to test the pipeline. These include publicly available ONT reads from open-access papers:

- _Streptococcus pyogenes_ (SRR22957083, isolate 221221SPYBC52) from a 2022 outbreak in London, United Kingdom by [Alcolea-Medina _et al._ 2023](https://doi.org/10.1016/j.cmi.2023.03.001)
- _Escherichia coli_ (SRR26162843, isolate IsolateD) from a 2023 validation of ONT sequencing for carbapenemase-producing organisms by [Lerminiaux _et al._ 2024](https://doi.org/10.1139/cjm-2023-0175)

These read sets were subsampled using [rasusa v2.0.0](https://github.com/mbhall88/rasusa) to obtain approximately 12-fold coverage (_S. pyogenes_) and 7-fold coverage (_E. coli_). Simulated human reads derived from the reference human genome GRCh38.p14 assembly in GenBank [GCA_000001405.29](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_000001405.29/) were obtained with [NanoSim v3.2.3](https://github.com/bcgsc/NanoSim) using the `human_giab_hg002_sub1M_kitv14_dorado_v3.2.1` pre-trained model. Human reads were concatenated with the subsampled isolate reads (n=1000 human reads for _S. pyogenes_, n=600 reads for _E. coli_).

To run the test dataset, the existing `test/samples.tsv` file is already configured for the test dataset:

| sample      | reads                                      |
| :---------- | :----------------------------------------- |
| SRR22957083 | test/SRR22957083_subset_withhuman.fastq.gz |
| SRR26162843 | test/SRR26162843_subset_withhuman.fastq.gz |

Start the workflow as normal:

```bash
nextflow run main.nf --profile singularity,test
```

The output `results/report.html` will show example results for both isolates.

## Core Nextflow arguments

> [!NOTE]
> These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen)

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Podman, Shifter, Charliecloud, Apptainer, Conda) - see below.

> [!IMPORTANT]
> We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended, since it can lead to different results on different machines dependent on the computer environment.

- `test`
  - A profile with a complete configuration for automated testing
  - Includes links to test data so needs no other parameters
- `docker`
  - A generic configuration profile to be used with [Docker](https://docker.com/)
- `singularity`
  - A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
- `podman`
  - A generic configuration profile to be used with [Podman](https://podman.io/)
- `shifter`
  - A generic configuration profile to be used with [Shifter](https://nersc.gitlab.io/development/shifter/how-to-use/)
- `charliecloud`
  - A generic configuration profile to be used with [Charliecloud](https://hpc.github.io/charliecloud/)
- `apptainer`
  - A generic configuration profile to be used with [Apptainer](https://apptainer.org/)
- `wave`
  - A generic configuration profile to enable [Wave](https://seqera.io/wave/) containers. Use together with one of the above (requires Nextflow ` 24.03.0-edge` or later).
- `conda`
  - A generic configuration profile to be used with [Conda](https://conda.io/docs/). Please only use Conda as a last resort i.e. when it's not possible to run the pipeline with Docker, Singularity, Podman, Shifter, Charliecloud, or Apptainer.

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

## Custom configuration

### Resource requests

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customise the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the pipeline steps, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher resources request (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.

### Custom Containers

In some cases, you may wish to change the container or conda environment used by a pipeline steps for a particular tool. By default, nf-core pipelines use containers and software from the [biocontainers](https://biocontainers.pro/) or [bioconda](https://bioconda.github.io/) projects. However, in some cases the pipeline specified version maybe out of date.

To use a different container from the default container or conda environment specified in a pipeline, please see the [updating tool versions](https://nf-co.re/docs/usage/configuration#updating-tool-versions) section of the nf-core website.

### Custom Tool Arguments

A pipeline might not always support every possible argument or option of a particular tool used in pipeline. Fortunately, nf-core pipelines provide some freedom to users to insert additional parameters that the pipeline does not include by default.

## Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted your job scheduler (from where it submits more jobs).

## Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```
