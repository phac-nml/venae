####################################
#
# Rules for species-specific tools
#
####################################


localrules:
    typing_concatenate_abricate_staph_toxins,
    typing_concatenate_emmtyper_strep_pyo,


# detect toxins in Staphylococcus aureus samples with VFDB via ABRicate
rule typing_abricate_staph_toxins:
    conda:
        "../envs/abricate_v1.0.1.yml"
    input:
        assembly=os.path.join(
            output_dir, "assembly_flye", "{sample}", "{sample}_flye.fasta"
        ),
    output:
        report=os.path.join(output_dir, "typing_staph_aureus", "{sample}_toxins.tsv"),
    params:
        extra=config["PARAMS"]["STAPH_AUREUS_TYPING"],
    threads: 1
    log:
        os.path.join(
            output_dir_logs, "typing_staph_aureus", "{sample}_typing_staph.out"
        ),
    benchmark:
        os.path.join(
            output_dir_benchmarks,
            "typing_staph_aureus",
            "{sample}_typing_staph_aureus_benchmark.out",
        )
    shell:
        """
        (abricate {params.extra} --db vfdb {input.assembly} > {output.report}) &> {log}
        """


# concatenate output of rule abricate_staph_toxins for all samples
rule typing_concatenate_abricate_staph_toxins:
    input:
        gather_files=get_staph_aureus,
    output:
        report=os.path.join(output_dir, "typing_staph_aureus_toxins.tsv"),
    params:
        gather_files=lambda wildcards, input: input.gather_files,
    threads: 1
    log:
        os.path.join(output_dir_logs, "typing_staph_aureus", "abricate_vfdb.out"),
    shell:
        """
        if [ ! -z {params.gather_files} ]; then
            (cat {params.gather_files} | sed 's/#FILE.*//g' | awk 'NF' > {output}) &> {log}
        else
            touch {output}
        fi
        """


# detect emm types in Streptococcus pyogenes samples using Emmtyper
rule typing_emmtyper_strep_pyo:
    conda:
        "../envs/emmtyper_v0.2.0.yml"
    input:
        assembly=os.path.join(
            output_dir, "assembly_flye", "{sample}", "{sample}_flye.fasta"
        ),
    output:
        report=os.path.join(output_dir, "typing_strep_pyo", "{sample}_emmtyper.tsv"),
    threads: 1
    params:
        db=config["DATABASES"]["EMMTYPER_DB"],
        extra=config["PARAMS"]["STREP_PYOGENES_TYPING"],
    log:
        os.path.join(output_dir_logs, "typing_strep_pyo", "{sample}_emmtyper.out"),
    benchmark:
        os.path.join(output_dir_benchmarks, "typing_strep_pyo", "{sample}_emmtyper.out")
    shell:
        """
        (emmtyper {input.assembly} --blast_db {params.db} -o {output.report} {params.extra}) &> {log}
        """


# concatenate output of rule emmtyper_strep_pyo for all samples
rule typing_concatenate_emmtyper_strep_pyo:
    input:
        gather_files=get_strep_pyo,
    output:
        report=os.path.join(output_dir, "typing_strep_pyo_emm.tsv"),
    params:
        gather_files=lambda wildcards, input: input.gather_files,
    threads: 1
    log:
        os.path.join(output_dir_logs, "typing_strep_pyo", "emmtyper.out"),
    shell:
        """
        if [ ! -z {params.gather_files} ]; then
            (cat {params.gather_files} > {output}) &> {log}
        else
            touch {output}
        fi
        """
