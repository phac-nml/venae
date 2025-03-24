####################################
#
# Rules for genome assembly
#
####################################


checkpoint assembly_flye:
    conda:
        "../envs/flye_v2.9.4.yml"
    input:
        reads=os.path.join(output_dir, "qc_reads", "{sample}_cleanfilt1k.fastq.gz"),
    output:
        assembly=os.path.join(output_dir, "assembly_flye", "{sample}_flye.fasta"),
    params:
        extra=config["PARAMS"]["FLYE"],
    threads: 8
    resources:
        mem_mb=2000,
    log:
        os.path.join(output_dir_logs, "assembly_flye", "{sample}_flye.out"),
    benchmark:
        os.path.join(
            output_dir_benchmarks, "assembly_flye", "{sample}_flye_benchmark.out"
        )
    shell:
        """
        (flye {params.extra} {input.reads} --out-dir results/assembly_flye/{wildcards.sample} --threads {threads}) &> {log} || true

        # copy assembly if it exists
        if [ -f results/assembly_flye/{wildcards.sample}/assembly.fasta ]; then
            cp results/assembly_flye/{wildcards.sample}/assembly.fasta results/assembly_flye/{wildcards.sample}/{wildcards.sample}_flye.fasta
            cp results/assembly_flye/{wildcards.sample}/assembly.fasta {output.assembly}
        
        # if it doesn't exist, make a fake output assembly so this rule completes
        else
            # if a previous dataset with same name exists already and was overwritten
            if [ -f {output.assembly} ]; then
                rm {output.assembly}
            fi
            
            touch {output.assembly}
        fi
        """
