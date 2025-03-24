####################################
#
# Rules for AMR detection
#
####################################


localrules:
    amr_kmerresistance_concatenate,
    amr_staramr_concatenate,


# predict AMR determinants from reads using KmerResistance
rule amr_kmerresistance:
    conda:
        "../envs/kmerresistance_v2.2.0.yml"
    input:
        reads=os.path.join(output_dir, "qc_reads", "{sample}_clean.fastq.gz"),
    output:
        report=os.path.join(output_dir, "amr_kmerresistance", "{sample}.KmerRes"),
    params:
        arg_db=config["DATABASES"]["KMERRESISTANCE_DB_ARG"],
        spp_db=config["DATABASES"]["KMERRESISTANCE_DB_SPP"],
        extra=config["PARAMS"]["KMERRESISTANCE"],
    threads: 1
    log:
        os.path.join(
            output_dir_logs, "amr_kmerresistance", "{sample}_kmerresistance.out"
        ),
    benchmark:
        os.path.join(
            output_dir_benchmarks,
            "amr_kmerresistance",
            "{sample}_kmerresistance_benchmark.out",
        )
    shell:
        """
        (kmerresistance -i {input.reads} -o results/amr_kmerresistance/{wildcards.sample} -t_db {params.arg_db} -s_db {params.spp_db} {params.extra}) &> {log}
        """


# concatenate output of KmerResistance from all samples
rule amr_kmerresistance_concatenate:
    input:
        expand(
            os.path.join(output_dir, "amr_kmerresistance", "{sample}.KmerRes"),
            sample=samples["sample"],
        ),
    output:
        os.path.join(output_dir, "amr_kmerresistance_summary.tsv"),
    threads: 1
    log:
        os.path.join(output_dir_logs, "amr_kmerresistance", "concatenate.out"),
    shell:
        """
        grep -H "" {input} | sed 's#.*Score.*##g;s#.KmerRes:#\t#g;s#results/amr_kmerresistance/##g;s#*NC_007795*$##g' | awk 'NF' | sort > {output}
        """


# predict AMR determinants from assemblies using StarAMR
rule amr_staramr:  # settings: 90% identity over 60% coverage
    conda:
        "../envs/staramr_v0.11.0.yml"
    input:
        assembly=os.path.join(
            output_dir, "assembly_flye", "{sample}", "{sample}_flye.fasta"
        ),
    output:
        report=os.path.join(
            output_dir, "amr_staramr", "{sample}", "{sample}_detailed_summary.tsv"
        ),
    threads: 1
    params:
        extra=config["PARAMS"]["STARAMR"],
        organism=get_pointfinder_organism,
    log:
        os.path.join(output_dir_logs, "amr_staramr", "{sample}_staramr.out"),
    benchmark:
        os.path.join(
            output_dir_benchmarks, "amr_staramr", "{sample}_staramr_benchmark.out"
        )
    shell:
        """
        # remove output folders if they exist, cannot force overwrite
        if [ -d results/amr_staramr/{wildcards.sample}/ ]; then
            rm -r results/amr_staramr/{wildcards.sample}/
        fi
        
        (staramr search -o results/amr_staramr/{wildcards.sample}/ {params.organism} {params.extra} {input}) &> {log}

        mv results/amr_staramr/{wildcards.sample}/detailed_summary.tsv {output.report}
        """


# concatenate output of StarAMR from all samples
rule amr_staramr_concatenate:
    input:
        gather_files=aggregate_amr_input,
    output:
        os.path.join(output_dir, "amr_staramr_detailed_summary.tsv"),
    threads: 1
    params:
        gather_files=lambda wildcards, input: input.gather_files,
    log:
        os.path.join(output_dir_logs, "amr_staramr", "concatenate.out"),
    shell:
        """
        if [[ -d results/amr_staramr ]]; then
            cat {params.gather_files} | sed 's#^Isolate.*##g' | awk 'NF' > {output}
        else 
            (echo ""
            echo "No samples had genome assemblies that could be run through StarAMR. Outputting empty file: {output}") &> {log}
            touch {output}
        fi
        """
