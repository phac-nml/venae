# = = = = = = = = = = = = = = = = =
# PURPOSE: 
#   Import sample names from samples.tsv specified in config
#
# INPUT: 
#   Path to sample sheet
#
# RETURN: 
#   Single-column tibble of sample names
# = = = = = = = = = = = = = = = = =
import_sample_names <- function(x) {
  read_tsv(x) %>% 
  select(sample) 
}

# = = = = = = = = = = = = = = = = =
# PURPOSE: 
#   Get list of missing/failed samples with no species ID
#
# INPUT: 
#   Sample name tibble and sylph tibble
#
# RETURN: 
#   Vector of sample names missing sylph organism ID
# = = = = = = = = = = = = = = = = =
get_missing_samples <- function(x, y){
  x %>%
  left_join(y, by = "sample") %>%
  filter(is.na(genus)) %>%
  pull(sample) 
}

# = = = = = = = = = = = = = = = = =
# PURPOSE: 
#   Import sylph taxonomy data
#
# INPUT: 
#   Path to sylph taxonomy file
#
# RETURN: 
#   Tibble with sylph taxonomy data
# = = = = = = = = = = = = = = = = =
import_sylph_tax <- function(x) {
  read_tsv(here(x), col_names = c("sample", "clade_name", "taxonomic_abundance", "sequence_abundance", "ani", "coverage"), col_types = "ccdddd") %>% 
  filter(str_detect(clade_name, "s__" )) %>% 
  filter(!str_detect(clade_name, "t__")) %>% 
  separate_wider_delim(clade_name, delim = "|", names = c("domain", "phyla", "class", "order", "family", "genus", "species")) %>%
  select(sample, order, genus, species, sequence_abundance) %>%
  mutate(sample = str_remove_all(sample, "results/spp_sylph/|_cleanfilt2k.fastq.gz.sylphmpa"),
          species = str_remove(species, "s__"),
          order = str_remove(order, "o__"),
          genus = str_remove(genus, "g__"),
          genus = str_remove(genus, "_[^[ ]]*$"),
          species = str_remove(species, "_[^[ ]]*"))
}

# = = = = = = = = = = = = = = = = =
# PURPOSE: 
#   Import Kraken2 taxonomy data
#
# INPUT: 
#   Path to Kraken2 taxonomy file
#
# RETURN: 
#   Tibble with Kraken2 taxonomy data
# = = = = = = = = = = = = = = = = =
import_kraken2_tax <- function(x) {
  read_tsv(x, col_types = "ccdiiccc", col_names = c("sample", "tool", "proportion", "count", "count2", "level", "taxid", "org")) %>% 
    filter(tool == "kraken2") %>% 
    filter(org != "root")   
}

# = = = = = = = = = = = = = = = = =
# PURPOSE: 
#   Import read quality metrics (post-host removal)
#
# INPUT: 
#   Path to read quality metrics file
#
# RETURN: 
#   Tibble with read quality data
# = = = = = = = = = = = = = = = = =
import_read_metrics <- function(x) {
  read_tsv(here(params$reads), col_types = "ccd", col_names = c("sample", "metric", "value")) %>% 
  select(sample, metric, value) %>% 
  mutate(sample = str_remove(sample, "results/")) %>%
  pivot_wider(id_cols = sample, names_from = metric, values_from = value) 
}

# = = = = = = = = = = = = = = = = =
# PURPOSE: 
#   Import StarAMR results
#
# INPUT: 
#   Path to StarAMR file
#
# RETURN: 
#   Tibble with StarAMR data
# = = = = = = = = = = = = = = = = =
import_staramr <- function(x) {
  read_tsv(x, col_types = "cccccddcc____", col_names = c("sample", "data", "data_type", "phenotype", "cge_phenotype", "perc_ident", "perc_coverage", "nucl", "contig")) %>% 
    mutate(sample = str_remove(sample, "_flye")) %>% 
    filter(data_type == "Resistance") %>% 
    select(sample, data, cge_phenotype, perc_ident, perc_coverage) %>% 
    distinct()
}

# = = = = = = = = = = = = = = = = =
# PURPOSE: 
#   Color text in report tables based on percentage values
#
# INPUT: 
#   Column name and threshold value for filtering
#
# RETURN: 
#   Color-coded numeric values for display in HTML tables
# = = = = = = = = = = = = = = = = =
color_code_gene_percentage <- function(x, y) {
  ifelse(x < y, cell_spec(x, "html", color = "#F8766D", bold = TRUE), cell_spec(x, "html", color = "#00BFC4", bold = TRUE))
}

