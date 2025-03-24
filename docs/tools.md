# Pipeline tools 

This page includes a description of all tools and databases used by **venae**. 

## Included tools

**venae** depends on multiple tools with individual conda environments. Snakemake will build these conda environments automatically using the .yml files in the `workflow/envs/` folder. 

This pipeline currently depends on the following programs and tools:

1. [NoHuman](https://github.com/mbhall88/nohuman) v0.3.0 (removes contaminating human reads)
2. [NanoQ](https://github.com/esteinig/nanoq) v0.2.1 (filters reads > 2000 bp for species classification and for reads > 1000 bp for assembly)
3. [NanoPlot](https://github.com/wdecoster/NanoPlot) v1.42.0 (outputs QC metrics for ONT reads)
4. [Kraken2](https://github.com/DerrickWood/kraken2) v2.1.4 (taxonomic classifer)
5. [Sylph](https://github.com/bluenote-1577/sylph) v0.8.0 (taxonomic profiler)
6. [Flye](https://github.com/fenderglass/Flye) v2.9.4 (long-read assembler)
7. [StarAMR](https://github.com/phac-nml/staramr) v0.11.0 (assembly-based antimicrobial resistance gene detection)
8. [KmerResistance](https://bitbucket.org/genomicepidemiology/kmerresistance/src/master/) v2.2.0 (read-based antimicrobial resistance gene detection)
9. [VFDB via ABRicate](https://github.com/tseemann/abricate) v1.0.1 (assembly-based virulence gene detection in *Staphylococcus aureus*) 
10. [emmtyper](https://github.com/MDU-PHL/emmtyper) v0.2.0 (assembly-based *emm* typing in *Streptococcus pyogenes*) 
11. [CheckM2](https://github.com/chklovski/CheckM2) v1.0.2 (assembly completeness score for bacteria)
12. [CoverM](https://github.com/wwood/CoverM) v0.7.0 (assembly coverage metrics)
13. [R](https://www.r-project.org/) v4.4.3 (final results report)

## Editing tool parameters

A list of tool parameters that can be modified in the configuation files can be found [here](../config/README.md).

## Database versions 

This pipeline currently makes use of the following default databases and files:

1. [NoHuman Kraken2 Human Pangenome Reference Consortium database](https://zenodo.org/records/8339732): v1 (2023-09)
2. [Kraken2 PlusPF database](https://benlangmead.github.io/aws-indexes/k2): plusPF-2024-12-28 8 Gb (RefSeq archaea, bacteria, viral, plasmid, human, protozoa, fungi, UniVec_Core)
3. [CheckM2 DIAMOND reference database](https://zenodo.org/records/5571251) v2
4. [StarAMR databases](https://github.com/phac-nml/staramr?tab=readme-ov-file#database-info-1): ResFinder Tue, 06 Aug 2024 11:26 (db commit d1e607b8989260c7b6a3fbce8fa3204ecfc09022), PointFinder Thu, 08 Aug 2024 11:57 (db commit 694919f59a38980204009e7ade76bf319cb7df0b), MLST v2.23.0 with db updated 2024-12-20
5. [VFDB database as part of ABRicate](https://github.com/tseemann/abricate?tab=readme-ov-file#databases): 2024-10-29 (4370 sequences) 
6. [ResFinder database](https://bitbucket.org/genomicepidemiology/resfinder_db/src/master/): v2.4.0 (2024-08-06) (indexed with kma using `-m 14` flag)
7. KmerFinder bacteria species database placeholder. See [the installation documentation](installation.md#kmerresistance) for more information. 
8. [Sylph databases](https://github.com/bluenote-1577/sylph/wiki/Pre%E2%80%90built-databases): bacteria dbv1 GTDB r220 (113,104 genomes 2024-04-24), fungal RefSeq v0.3 -c200 2024-07-25 (595 genomes)
9. [Sylph taxonomy databases](https://github.com/bluenote-1577/sylph-tax): bacteria GTDB r220, fungal RefSeq 2024-07-25
10. [emmtyper databases](https://ftp.cdc.gov/pub/infectious_diseases/biotech/tsemm/): 2024-10-29 (2570 sequences)

Some tools will automatically install their own databases (ABRicate, StarAMR, AMRFinderPlus), and other small databases are included in the pipeline download (ResFinder, KmerFinder, emmtyper). To manually install required databases for other tools, see [the installation documentation](installation.md#database-installation).

## Notes on specific tools and steps

### Host removal 

The first step of the pipeline (NoHuman) removes any host-associated reads by classifying reads against a Kraken2 database built from all of the genomes in the Human Pangenome Reference Consortium's (HPRC) [first draft human pangenome reference](https://www.nature.com/articles/s41586-023-05896-x). The QC tool NanoPlot is run before and after this step to measure the proportion of host DNA being sequenced/removed. 

[Hostile](https://github.com/bede/hostile) was also evaluated for human read removal (read the paper [here](https://doi.org/10.1093/bioinformatics/btad728)). On average, NoHuman removed 4% more human reads than Hostile and NoHuman ran 100s faster than Hostile. 

### Read filtering

Following the host-removal step, the reads are passed through two filtering steps with NanoQ: Q-score > 10 and length > 2000 bp for species detection (as recommended in [Portik *et al.* 2022](https://doi.org/10.1186/s12859-022-05103-0)), and Q-score > 10 and length > 1000 bp for assembly (based on internal validation that assembly quality improved with Q-score filtering compared to raw reads, but 2000 bp length filtering was detrimental at earlier timepoints when there is less data). 

[Filtlong](https://github.com/rrwick/Filtlong) and [Chopper](https://github.com/wdecoster/chopper) were also evaluted. NanoQ was chosen as it can output a short summary report (eliminating the need to run extra NanoPlot steps) and gzip files in the same command. 

### Species identification

This workflow currently depends on two tools for species identification: taxonomic classifier Kraken2 and taxonomic profiler Sylph. Kraken2 is alignment-based tool that aligns reads to an existing database and assign an organism to every read. Sylph is a k-mer-based profiler that determines the abundance of different organisms in a sample. 

In the final output report, "Level 1" species identification is performed with Kraken2 due to low read counts. "Level 2" species identification is performed with Sylph when there are sufficient for k-mer analysis (approximately ~100 reads > 2 kb but specific threshold is not defined and likely varies by organism). 

Based on internal validations, both Kraken2 and Sylph accurately assess organism identity for both bacteria and fungi. However, Kraken2's databases have several artifacts that result in multiple species being detected in certain cases due to similarity in reference sequences, particularly for *Bacillus*, *Citrobacter*, and *Klebsiella*, as opposed to the methodology used by Sylph. Consequently, Sylph is used to output final species identity as it is more accurate in identifying true polymicrobial cases. 

[Metabuli](https://github.com/steineggerlab/Metabuli) is a newer profiler that was evaluated for species identification (read the paper [here](https://doi.org/10.1038/s41592-024-02273-y)). However, this tool was eliminated from the pipeline as currently there are no suported fungi databases so requires building a custom fungi database. The resulting database of fungi and bacteria RefSeq organisms used for testing here was quite large (~ 470 Gb) and the pre-built GTDB and RefSeq bacteria databases were also > 100 Gb each. Databases that size will unreasonable for some users, and tool runtime was quite high likely due to database size.

### KmerResistance

Reads (all sizes and Q-scores) are scanned for AMR using KmerResistance after host removal. The detection limit to this tool is a single read so results should be interpreted with caution, particularly for specific allele types. 

KMA v1.4.9 includes a preset flag `-ont` which has been optimized for gene querying with noisy long reads. This flag is included in the `kmerresistance` call and does produce a different output compared to when it is not included. 

For more details about the KmerResistance databases, see [the installation documentation](installation.md#kmerresistance)

### StarAMR

This program has the option to specify an `--pointfinder-organism` parameter which leads to better antimicrobial resistance gene predictions. Currently, this workflow pulls the list of species identified for each sample and searches against a list of organisms included in AMRFinderPlus (`resources/pointfinder_organism.tsv`) to assign the correct organism for each sample if applicable (`rule spp_assign_organism_amr` using the `workflow/scripts/assign_organism_amr.py` script). It then includes the `--pointfinder-organism` parameter (using the `get_pointfinder_organism` function) in the StarAMR call (`rule staramr`) if a matching organism was found in the list. 

This will currently not work if there are two matching organism hits in the same sample (i.e. a mixed sample of two or more organisms that are represented in the AMRFinderPlus database). Only one will be run. 

There are probably more elegant ways of doing this, but this hacky-python-beginner solution is working for now!

For the list of available PointFinder organisms, see [the list on the StarAMR GitHub page](https://github.com/phac-nml/staramr?tab=readme-ov-file#caveats). 

### Outputting HTML results report

The final HTML results report is generated using [R v4.4.3](https://www.R-project.org/) and the following packages, many of which are part of the [tidyverse suite](https://tidyverse.tidyverse.org/articles/paper.html): 
    - [rmarkdown v2.29](https://rmarkdown.rstudio.com/)
    - [rbookdown v0.42](https://bookdown.org/)
    - [here v1.0.1](https://here.r-lib.org/)
    - [readr v2.1.5](https://readr.tidyverse.org/)
    - [dplyr v1.1.4](https://dplyr.tidyverse.org/)
    - [stringr v1.5.1](https://stringr.tidyverse.org/)
    - [tidyr v1.3.1](https://tidyr.tidyverse.org/)
    - [formattable v0.2.1](https://cran.r-project.org/web/packages/formattable/index.html)
    - [kableExtra v1.4.0](https://haozhu233.github.io/kableExtra/)
    - [tibble v3.2.1](https://tibble.tidyverse.org/)
    - [plotly v4.10.4](https://plotly.com/r/)
    - [patchwork v1.3.0](https://patchwork.data-imaginist.com/)

## Documentation

- [Installation](installation.md)
- [Configuration](../config/README.md)
- [Usage](usage.md)
- [Output](output.md)
- [Tools](tools.md)
- [Citations](../CITATIONS.md)
