# venae: Output

This page includes a description of all files output by **venae** in the output folder.

## Index

- [Report file](#report-file)
  - [Summary results](#summary-results)
  - [Detailed results](#detailed-results)
    - [Sequencing Metrics](#sequencing-metrics)
    - [Organism Identification](#organism-identification)
    - [Antimicrobial Resistance](#antimicrobial-resistance)
  - [Methods](#methods)
  - [Disclaimer](#disclaimer)
  - [Data Dictionary](#data-dictionary)
- [Detailed results files](#detailed-results-files)
  - [Species-specific typing results](#species-specific-typing-results)
  - [Fungi samples](#fungi-samples)
- [Pipeline information](#pipeline-information)
- [Antimicrobial resistance results filtered by the CLSI M100 document](#antimicrobial-resistance-results-filtered-by-the-clsi-m100-document)

## Report file

The `report.html` final report output in the output folder, which can be viewed through a web browser. This file has the following structure:

### Summary results

This section includes metadata including custom run name and sampling time, and a Summary Table with the following headings:

| Heading                        | Definition                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| :----------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sample                         | Name of each sample                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| Organism                       | List of species identified in each sample                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| Polymicrobial                  | yes/no indicating if the sample is polymicrobial \(2 or more organisms\)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| QC                             | pass/fail indicating if sample passed quality control metrics                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| Predicted resistance phenotype | List of antimicrobials for which resistances genes were detected in the sample. This list is derived from the Centre for Genomic Epidemiology ResFinder database does not represent all resistant determinants or point mutations. Predicted phenotypes only show those antimicrobials included in the Clinical and Laboratory Standards Institute document Performance Standards for Antimicrobial Susceptibility Testing: Informational Supplement M100 ED35\:2025 Table 1 \(Tier 1 and Tier 2\). Please see [this table](#antimicrobial-resistance-results) for the full list of reportable antimicrobials in Tier 1 and Tier 2 for each organism. “Could not predict” indicates AMR prediction is not supported for this organism or that there was not enough sequencing data to generate an assembly. |

![Example of the Summary Results table output in the final report](docs/images/summary_table.png "Example of the Summary Results table output in the final report"){width=50%}

### Detailed results

This section contains specific subsections for detailed results for the following:

- [Sequencing metrics](#sequencing-metrics)
- [Organism identification](#organism-identification)
- [Antimicrobial resistance](#antimicrobial-resistance)

#### Sequencing Metrics

Sequencing metrics which include sequencing read quality and length metrics are output in Table 2.

| Heading                                                             | Definition                                                                                                                                                                                                                                                                                           |
| :------------------------------------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sample                                                              | Name of each sample                                                                                                                                                                                                                                                                                  |
| Real-time genome assembly stats: Completeness (%)                   | Percent of lineage-specific marker genes that are present in the assembly. NA indicates no assembly for this isolate or that this isolate is a polymicrobial culture or fungus. Note AMR phenotypes may be missing if completeness < 90 %.                                                           |
| Real-time genome assembly stats: Assembled depth of coverage (fold) | Average depth of coverage calculated by mapping reads back to the assembly                                                                                                                                                                                                                           |
| Real-time genome assembly stats: Assembled size (Mb)                | Size of assembled genome in megabases                                                                                                                                                                                                                                                                |
| Estimated genome assembly stats: Estimated depth of coverage (fold) | Estimated depth of coverage calculated by dividing the estimated size (Mb) by the total number of bases sequenced. Values below 5X are flagged in red and values below 10X are flagged in yellow. NA indicates not enough reads to identify an organism in that sample.                              |
| Estimated genome assembly stats: Estimated size (Mb)                | Estimated size of assembled genome is a sum of genome sizes for all organisms found in the sample. Estimated size was obtained from the average size of all assembled RefSeq genomes for each genus in the Bacteria (taxid:2) dataset from the National Center for Biotechnology Information (NCBI). |
| Read and Q-scores: % reads > 1 kb and Q-score > 10                  | Percentage of reads sequenced that are greater than 1 kb in length and have a Q-score greater than 10                                                                                                                                                                                                |
| Read and Q-scores: % bases > 1 kb and Q-score > 10                  | Percentage of bases sequenced that are greater than 1 kb in length and have a Q-score greater than 10                                                                                                                                                                                                |
| Read and Q-scores: Number of reads > 1 kb                           | Number of reads sequenced that are greater than 1 kb in length                                                                                                                                                                                                                                       |
| Read and Q-scores: Median read length (kb)                          | Median read length of all reads greater than 1 kb sequenced                                                                                                                                                                                                                                          |
| Read and Q-scores: Median read quality (Q-score)                    | Median read length of all reads greater than 1 kb sequenced                                                                                                                                                                                                                                          |

![Example of the Sequencing Metrics table output in the final report](docs/images/sequencing_metrics.png "Example of the Sequencing Metrics table output in the final report"){width=50%}

#### Organism Identification

This section contains a two-panel figure. The first panel is a stacked barplot with sample name on the y-axis and percent sequence abundance on the x-axis. Sequence abundance indicates the percentage of reads assigned to each organism in the sample. Hovering over each bar will show species identity and proportion of reads allocated. Grey bars indicate unclassified reads. The barplot on the right indicates the number of reads > 2 kb in length that were used for species identification. Performing taxonomic classification and profiling with long-read sequences revelaed that reads over 2 kb in length had more accurate results based on [Portik _et al_. 2022 BMC Bioinformatics](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-022-05103-0).

![Example of the Organism Identification figure output in the final report](docs/images/organism_identification.png "Example of the Organism Identification figure output in the final report"){width=50%}

The _Staphylococcus aureus_ toxins section contains a list of _S. aureus_ isolates for which toxin typing was performed. If there are no _S. aureus_ isolates detected, this header will still exist but there will be no data table. Note that this tool requires an assembly to run. The Virulence Factor Database (VFDB) is used to screen for the following toxin genes: _sea_, _seb_, _sec_, _sed_, _see_, _seh_, _selk_, _sell_, _selq_, _tsst_, _eta_, _etb_, _luk_. The following results are output:

| Heading              | Definition                                                                                                                                                                                                                          |
| :------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sample               | Name of each sample                                                                                                                                                                                                                 |
| Gene                 | Name of toxin gene detected. NA indicates no toxin genes detected in this sample.                                                                                                                                                   |
| Percent identity (%) | Percent nucleotide identity of toxin gene identified in assembly relative to the reference sequence in the Virulence Factor Database (VFDB). Percent identity below 98 % are flagged in red and should be interpreted with caution. |
| Percent coverage (%) | Percent nucleotide length of toxin gene in assembly that cover the length of the reference sequence in VFDB. Percent coverage below 90 % are flagged in red and should be interpreted with caution.                                 |

The _Streptococcus pyogenes_ _emm_-typing section contains the predicted _emm_ type and cluster for each _S. pyogenes_ isolate based on the U.S. Centers for Disease Control and Prevention trimmed _emm_ subtype database.

| Heading              | Definition                                                                                            |
| :------------------- | :---------------------------------------------------------------------------------------------------- |
| Sample               | Name of each sample                                                                                   |
| Predicted _emm_ type | _emm_ type detected. NA indicates no _emm_ type was detected, possibly due to an incomplete assembly. |
| _emm_ cluster        | Percent nucleotide identity of toxin gene identified in assembly to the reference sequence            |

#### Antimicrobial Resistance

This section contains two tables corresponding to AMR detection using two different tools that both rely on the Centre for Genomic Epidemiology databases and the corresponding Predicted Phenotypes for each gene.

Both StarAMR (assembly-based) and KmerResistance (read-based) include tables with the following headings:

| Heading                        | Definition                                                                                                                                                                                                                                                                                             |
| :----------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sample                         | Name of each sample                                                                                                                                                                                                                                                                                    |
| Gene                           | Name of toxin gene detected. NA indicates no toxin genes detected in this sample.                                                                                                                                                                                                                      |
| Percent identity (%)           | Percent nucleotide identity of AMR gene identified in assembly relative to the reference sequence. Percent identity below 98 % are flagged in red and should be interpreted with caution.                                                                                                              |
| Percent coverage (%)           | Percent nucleotide length of AMR gene in assembly that cover the length of the reference sequence. Percent coverage below 90 % are flagged in red and should be interpreted with caution.                                                                                                              |
| Predicted resistance phenotype | Predicted phenotype is derived from the Centre for Genomic Epidemiology ResFinder database and does not represent all resistant determinants or point mutations. These phenotypes have not been completely validated in all organisms and may not represent the true phenotype for each antimicrobial. |

![Example of the Antimicrobial Resistance table output in the final report](docs/images/antimicrobial_resistance.png "Example of the Antimicrobial Resistance table output in the final report"){width=50%}

### Methods

This section includes a detailed description of methods and tools used to generate results for this report.

### Disclaimer

This section includes a disclaimer statement. It also includes a list of those antimicrobials included in the Clinical and Laboratory Standards Institute document [Performance Standards for Antimicrobial Susceptibility Testing: Informational Supplement M100 ED35:2025](https://clsi.org/standards/products/microbiology/documents/m100/) Table 1 (Tier 1 and Tier 2) that are evaluted in this pipeline. See [here](#antimicrobial-resistance-results-filtered-by-the-clsi-m100-document) for more information.

### Data Dictionary

This section includes definitions for abbreviations used in the report.

## Detailed results files

The following files are output in the output folder (default name: `results/`):

1. `amr_chroquetas_summary.tsv`: a list of AMR mutations detected in each fungi sample by ChroQueTas (file will be absent if no fungi detected)
2. `amr_kmerresistance_summary.tsv`: a list of ARGs detected in each sample by KmerResistance
3. `amr_staramr_detailed_summary.tsv`: a list of ARGs detected in each bacterial sample by StarAMR
4. `qc_assembly_checkm2.tsv`: a list of assembly completeness scores and quality metrics metrics (N50, number of contigs, etc.) for each sample
5. `qc_assembly_coverage.tsv`: a list of mean assembly coverage based on read mapping and total length in base pairs of assembled genome
6. `qc_failed_assemblies.txt`: a list of samples that did not assemble due to low read coverage (file will be absent if all samples generated an assembly)
7. `qc_host_removed.tsv`: a summary of the proportion of host reads removed from each sample by NoHuman
8. `qc_read_metrics_clean.tsv`: a summary of total bases and read statistics from each sample with host removed generated by NanoPlot
9. `qc_read_metrics_cleanfilt.tsv`: a summary of total bases and read statistics from each sample with host removed, filtered for reads > 1kb and > 2 kb and Q-score > 10 used for assembly generated by NanoPlot
10. `spp_assigned.tsv`: a list of organism-specific databases for PointFinder/StarAMR used for each sample
11. `spp_fungi_samples.tsv`: a list of fungi samples (file will be empty if no fungi detected)
12. `spp_kraken2_classification.tsv`: a summary of species detected in each sample by taxonomic classifier Kraken2
13. `spp_sylph_profile.tsv`: a summary of species detected from all samples by taxonomic profiler Sylph
14. `spp_sylph_taxonomy.tsv`: a list of taxonomic rankings for organisms in each sample identified by Sylph

The following folders are output in the output folder (default name: `results/`) and contain specific files for each sample:

1. `amr_kmerresistance/`: contains output KmerResistance .KmerRes files for each sample (note: the species identification is not reliable and should be ignored)
2. `amr_staramr/`: contains sub-folders for each sample with StarAMR output
3. `assembly_flye/`: contains the Flye assembly for each sample and sub-folders with Flye output and assembly graphs for each sample
4. `benchmarks/`: contains the benchmark files for each resource-intensive step in the pipeline
5. `logs/`: contains sub-folders for each step in the workflow containing log files output by each tool
6. `qc_checkm2/`: contains intermediate files output by CheckM2
7. `qc_coverm/`: contains files with coverage and length values output by CoverM for each sample
8. `qc_nanoplot/`: contains folders with read metrics output by NanoPlot for each set of filtered reads for each sample
9. `qc_nanoq/`: contains summary files for each set of filtered reads for each sample
10. `qc_reads/`: contains cleaned and filtered read files for each sample
11. `spp_kraken2/`: contains a report file output by Kraken2 for each sample
12. `spp_sylph/`: contains one report file and individual sample indexes output by Sylph

The following folders are output in the output folder (default name: `results/`) and contain log files for each tool and pipeline information output by Nextflow:

1. `logs/`: contains log files output by each tool for each sample
2. `pipeline_info/`: contains Nextflow execution reports for each pipeline invocation

### Species-specific typing results

1. `typing_staph_toxins.tsv` and `typing_staph_aureus/`: list of toxin genes detected in _Staphylococcus aureus_ using VFDB via ABRicate. If this file is empty or if this folder does not exist, this indicates no _Staphylococcus aureus_ were detected or that there is not enough read coverage of _S. aureus_ to generate an assembly.
2. `typing_strep_pyo_emmtyper.tsv` and `typing_strep_pyo/`: list of _emm_ types detected in _Streptococcus pyogenes_ using emmtyper. If this file is empty or if this folder does not exist, this indicates no _Streptococcus pyogenes_ were detected or that there is not enough read coverage of _S. pyogenes_ to generate an assembly.

### Fungi samples

If a sample is identified as containing a yeast/fungus (_Nakaseomyces glabratus_, _Candida albicans_, _Candida auris_, _Candida parapsilosis_, etc.), it will run through the assembly-based AMR detection tool ChroQueTas. In addition, it will not have accurate predictions for read-based AMR detection (KmerResistance) nor will it be assigned an assembly completeness value (CheckM2).

## Pipeline information

The following pipeline information is printed in the output folder in the `pipeline_info` folder:

1. Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
2. Parameters used by the pipeline run: `params.json`.
3. Tool versions used by the pipeline: `venae_software_versions.yml`

## Antimicrobial resistance results filtered by the CLSI M100 document

Predicted resistance phenotypes output in the Summary Table of the `report.html` file only show those antimicrobials included in the Clinical and Laboratory Standards Institute document [Performance Standards for Antimicrobial Susceptibility Testing: Informational Supplement M100 ED35:2025](https://clsi.org/standards/products/microbiology/documents/m100/) Table 1 (Tier 1 and Tier 2). Please see the following table for the full list of reportable antimicrobials in Tier 1 and Tier 2 for each organism:

| CLSI Table | Organism                         | Antibiotics                                                                                                                                                                                                                                                                                                    |
| :--------- | :------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Table1A-1  | _Enterobacterales_               | Amikacin, Amoxicillin+Clavulanate, Ampicillin, Ampicillin+Sulbactam, Cefazolin, Cefepime, Cefotaxime, Cefotetan, Cefoxitin, Ceftriaxone, Cefuroxime, Ciprofloxacin, Ertapenem, Gentamicin, Imipenem, Levofloxacin, Meropenem, Piperacillin+Tazobactam, Tetracycline, Tobramycin, Trimethoprim+Sulfamethoxazole |
| Table1A-2  | _Salmonella, Shigella_           | Ampicillin, Azithromycin, Cefotaxime, Ceftriaxone, Ciprofloxacin, Levofloxacin, Trimethoprim+Sulfamethoxazole                                                                                                                                                                                                  |
| Table1B-1  | _Pseudomonas_                    | Cefepime, Ceftazidime, Ciprofloxacin, Imipenem, Levofloxacin, Meropenem, Piperacillin+Tazobactam, Tobramycin                                                                                                                                                                                                   |
| Table1B-2  | _Acinetobacter_                  | Amikacin, Cefepime, Ceftazidime, Ciprofloxacin, Gentamicin, Imipenem, Levofloxacin, Meropenem, Minocycline, Piperacillin+Tazobactam, Tazobactam, Tobramycin, Trimethoprim+Sulfamethoxazole                                                                                                                     |
| Table1B-4  | _Stenotrophomonas_               | Levofloxacin, Minocycline, Trimethoprim+Sulfamethoxazole                                                                                                                                                                                                                                                       |
| Table1B-5  | _Non-Enterobacterales_           | Amikacin, Aztreonam, Cefepime, Ceftazidime, Ciprofloxacin, Gentamycin, Imipenem, Levofloxacin, Meropenem, Minocycline, Piperacillin+Tazobactam, Tobramycin, Trimethoprim+Sulfamethoxazole                                                                                                                      |
| Table1C    | _Staphylococcus_                 | Azithromycin, Cefoxitin, Clarithromycin, Clindamycin, Daptomycin, Doxycycline, Erythromycin, Linezolid, Minocycline, Oxacillin, Penicillin, Tetracycline, Trimethoprim+Sulfamethoxazole, Vancomycin                                                                                                            |
| Table1D    | _Enterococcus_                   | Ampicillin, Daptomycin, Gentamicin, Linezolid, Penicillin, Vancomycin                                                                                                                                                                                                                                          |
| Table1E    | _Haemophilus influenzae_         | Amoxicillin+Clavulanate, Ampicillin, Ampicillin+Sulbactam, Cefotaxime, Ceftazidime, Ceftriaxone, Ciprofloxacin, Levofloxacin, Moxifloxacin, Trimethoprim+Sulfamethoxazole                                                                                                                                      |
| Table1G    | _Streptococcus pneumoniae_       | Cefotaxime, Ceftriaxone, Clindamycin, Doxycycline, Erythromycin, Levofloxacin, Meropenem, Moxifloxacin, Penicillin, Tetracycline, Trimethoprim+Sulfamethoxazole, Vancomycin                                                                                                                                    |
| Table1H-1  | _Streptococcus_ (Group A and B)  | Ampicillin, Clindamycin, Erythromycin, Penicillin, Tetracycline                                                                                                                                                                                                                                                |
| Table1H-2  | _Streptococcus_ (Viridans group) | Ampicillin, Cefotaxime, Ceftriaxone, Penicillin, Vancomycin                                                                                                                                                                                                                                                    |
| Table1I    | _Neisseria meningitidis_         | Cefotaxime, Ceftriaxone, Penicillin                                                                                                                                                                                                                                                                            |

**NOTE**: this workflow cannot confirm the following Tier 1 and Tier 2 antimicrobials:

- _Enterobacterales_: Ampicillin+Sulbactam
- _Enterobacterales_, _Salmonella_, _Shigella_, _Pseudomonas aeruginosa_, _Stenotrophomonas_, _Burkholderia_, non-_Enterobacterales_ Gram negatives, and _Streptococcus pneumoniae_: Levofloxacin
- _Staphylococcus_ species and _Enterococcus_ species: Daptomycin
- _Streptococcus pneumoniae_: Moxifloxacin
- _Neisseria meningitidis_: Cefotaxime, Ceftriaxone, Penicillin

## Documentation

- [Installation](installation.md)
- [Configuration](config.md)
- [Usage](usage.md)
- [Output](output.md)
- [Tools](tools.md)
- [Citations](../CITATIONS.md)
