####################################
#
# Helper functions
#
####################################


# = = = = = = = = = = = = = = = = =
# PURPOSE:
#   Get read inputs from paths in sample sheet
#
# INPUT:
#   Sample wildcards
#
# RETURN:
#   Read filename for each sample
# = = = = = = = = = = = = = = = = =
def get_reads(wildcards):
    fname = samples.loc[wildcards.sample, "reads"]
    return fname


# = = = = = = = = = = = = = = = = =
# PURPOSE:
#   Get --pointfinder-organism value for StarAMR
#
# INPUT:
#   Sample wildcards and spp_assigned.tsv containing list of params per sample
#
# RETURN:
#   String to include in StarAMR command that includes the value for --pointfinder-organism argument or omit if none
# = = = = = = = = = = = = = = = = =
def get_pointfinder_organism(wildcards):
    mydict = {}
    with open(os.path.join(output_dir, "spp_assigned.tsv"), "r") as f:
        for row in csv.DictReader(f, delimiter="\t"):
            mydict[row["sample"]] = row["pointfinder_organism"]
        if not mydict[wildcards.sample]:
            return ""
        else:
            return f" --pointfinder-organism " + mydict[wildcards.sample]


# = = = = = = = = = = = = = = = = =
# PURPOSE:
#   Get list of assemblies for StarAMR analysis
#
# INPUT:
#   Sample wildcards, list of fungi samples, and completed Flye assemblies
#
# RETURN:
#   String of non-empty assembly files eligible for StarAMR analysis
# = = = = = = = = = = = = = = = = =
def aggregate_amr_input(wildcards):
    files = []
    fungi = checkpoints.spp_assign_organism_amr.get(**wildcards).output.fungi
    with open(fungi, mode="r") as infile:
        reader = csv.reader(infile, delimiter="\t")
        mydict = {rows[0]: rows[1] for rows in reader}
    for sample in samples["sample"]:
        fn = checkpoints.assembly_flye.get(sample=sample).output[0]
        if sample in mydict.keys():
            continue
        elif os.stat(fn).st_size > 0:
            files.append(
                os.path.join(
                    output_dir,
                    "amr_staramr",
                    "{sample}",
                    "{sample}_detailed_summary.tsv",
                ).format(sample=sample)
            )
    return files


# = = = = = = = = = = = = = = = = =
# PURPOSE:
#   Get list of assemblies for assembly QC analysis
#
# INPUT:
#   Sample wildcards, list of fungi samples, and completed Flye assemblies
#
# RETURN:
#   String of non-empty assembly files eligible for assembly QC analysis
# = = = = = = = = = = = = = = = = =
def aggregate_assembly_input(wildcards):
    files = []
    fungi = checkpoints.spp_assign_organism_amr.get(**wildcards).output.fungi
    with open(fungi, mode="r") as infile:
        reader = csv.reader(infile, delimiter="\t")
        mydict = {rows[0]: rows[1] for rows in reader}
    for sample in samples["sample"]:
        fn = checkpoints.assembly_flye.get(sample=sample).output[0]
        if sample in mydict.keys():
            continue
        elif os.stat(fn).st_size > 0:
            files.append(
                os.path.join(output_dir, "assembly_flye", "{sample}_flye.fasta").format(
                    sample=sample
                )
            )
    return files


# = = = = = = = = = = = = = = = = =
# PURPOSE:
#   Get list sample wildcards matching specific organism ID
#
# INPUT:
#   File with species assigned to each sample, and target species
#
# RETURN:
#   Sample wildcards matching organism
# = = = = = = = = = = = = = = = = =
def find_key(file, species):
    with open(file, mode="r") as infile:
        reader = csv.reader(infile, delimiter="\t")
        mydict = {rows[0]: rows[1] for rows in reader}
    return {k for k, v in mydict.items() if v == species}


# = = = = = = = = = = = = = = = = =
# PURPOSE:
#   Get list of assemblies for Staph aureus toxin analysis
#
# INPUT:
#   Sample wildcards, list of Staph aureus samples, and completed Flye assemblies
#
# RETURN:
#   String of non-empty assembly files eligible for Staph aureus toxin analysis
# = = = = = = = = = = = = = = = = =
def get_staph_aureus(wildcards):
    files = []
    fn = checkpoints.spp_assign_organism_amr.get(**wildcards).output.assigned
    for sample in find_key(fn, "Staphylococcus aureus"):
        assembly = checkpoints.assembly_flye.get(sample=sample).output[0]
        if os.stat(assembly).st_size > 0:
            files.append(
                os.path.join(
                    output_dir, "typing_staph_aureus", "{sample}_toxins.tsv"
                ).format(sample=sample)
            )
    return files


# = = = = = = = = = = = = = = = = =
# PURPOSE:
#   Get list of assemblies for Strep pyogenes emm analysis
#
# INPUT:
#   Sample wildcards, list of Strep pyogenes samples, and completed Flye assemblies
#
# RETURN:
#   String of non-empty assembly files eligible for Strep pyogenes emm toxin analysis
# = = = = = = = = = = = = = = = = =
def get_strep_pyo(wildcards):
    files = []
    fn = checkpoints.spp_assign_organism_amr.get(**wildcards).output.assigned
    for sample in find_key(fn, "Streptococcus pyogenes"):
        assembly = checkpoints.assembly_flye.get(sample=sample).output[0]
        if os.stat(assembly).st_size > 0:
            files.append(
                os.path.join(
                    output_dir, "typing_strep_pyo", "{sample}_emmtyper.tsv"
                ).format(sample=sample)
            )
    return files
