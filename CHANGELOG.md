# venae: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.2.2 (February 2026)

This release fixed minor bugs in the report and updated the Methods text printed in the report.

### Fixed:

- Fix bug concatenating StarAMR and ChroQueTas results into Summary table in the report
- Fix bug printing ChroQueTas AMR table in report when there are assemblies but no hits
- Fix bug printing empty string for predicted phenotype in Summary table in the report
- Fix typo in AMR section of the report

### Added:

- Add `meta` to `Flye v2.9.4` in the Methods text in the report

### Removed:

- Remove KmerFinder bacteria database reference for KmerResistance in Methods text in the report

## v0.2.1 (September 2025)

This release added ChroQueTas (fungi AMR tool) to the workflow & report which will run if fungi organisms are detected

### Added:

- Add ChroQueTas tool for fungi AMR detection
- Add ChroQueTas species list as a resource for species-specific AMR
- Add hyperlinks to species identity figure in report

### Fixed:

- Fix output for qc_failed_assemblies.txt
- Fix version output by KmerResistance
- Fix dataflow so that samples mixed with fungi and bacteria are input into both fungi and bacteria AMR tools

### Changed:

- Change shell directives for Flye to ignore errors and output empty assembly file if tool fails
- Update report disclaimer for resistant phenotypes
- Update docs to include ChroQueTas
- Change dataflow into CoverM to avoid mismatched assemblies/reads
- Change sylph/sketch to local modules

### Removed:

- Remove lab-based DNA extraction and sequencing methods boilerplate from report template

## v0.2.0 (September 2025)

This release reformatted the codebase from Snakemake to Nextflow

### Changed:

- Reformatted codebase from Snakemake to Nextflow

## v0.1.2 (August 2025)

### Fixed:

- Antibiotics in Table1H-2 _Streptococcus_ VGS now correct based on CLSI ED35:2025
- Removed individual drugs that were present in combos from CLSI Table1s

### Changed:

- Update default resourves for Flye, Sylph, CheckM2
- Kraken2 filtered reports now output into subfolder `spp_kraken2`
- NanoPlot now outputs correctly-formatted TSV file

### Added:

- Add _Streptococcus infantis_ to CLSI key
- Output concatenated Kraken2 file into output directory

## v0.1.1 (April 2025)

### Fixed:

- Allow for custom output folder name for results
- Allow for sample to have assembly but no species ID from sylph
- Broken run name in report header
- Parsing input string of concatenate rules for typing rules
- Removed leftover parameters and outputs that were no longer used

### Changed:

- Memory requirements for kraken2 changed from 16 Gb in rule to 10 Gb
- Parsing of kraken2 species ID when sylph is missing ID in report

## v0.1.0 (March 2025)

### Notes

This is the first public release of the `venae` pipeline. This pipeline uses Snakemake to identify species and antimicrobial resistance determinants from positive blood cultures and produces a final HTML report.
