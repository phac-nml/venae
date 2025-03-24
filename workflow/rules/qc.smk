####################################
#
# Rules for quality reports
#
####################################


localrules:
    qc_remove_host_stats,
    qc_read_metrics,
    qc_failed_assemblies,
    qc_coverage_concatenate,


# remove host
rule qc_remove_host:
    conda:
        "../envs/nohuman_v0.3.0.yml"
    input:
        get_reads,
    output:
        os.path.join(output_dir, "qc_reads", "{sample}_clean.fastq.gz"),
    params:
        db=config["DATABASES"]["NOHUMAN_DB"],
        extra=config["PARAMS"]["NOHUMAN"],
    threads: 4
    resources:
        mem_mb=6000,
    log:
        os.path.join(output_dir_logs, "qc_remove_host", "{sample}_nohuman.out"),
    benchmark:
        os.path.join(
            output_dir_benchmarks, "qc_remove_host", "{sample}_nohuman_benchmark.out"
        )
    shell:
        "(nohuman -o {output} --db {params.db} --threads {threads} {params.extra} {input}) &> {log}"


# filt reads and output summary file
rule qc_nanoq:
    conda:
        "../envs/nanoq_v0.10.0.yml"
    input:
        reads=os.path.join(output_dir, "qc_reads", "{sample}_clean.fastq.gz"),
    output:
        spp=temp(os.path.join(output_dir, "qc_reads", "{sample}_cleanfilt2k.fastq.gz")),
        assembly=temp(
            os.path.join(output_dir, "qc_reads", "{sample}_cleanfilt1k.fastq.gz")
        ),
        sppreport=os.path.join(
            output_dir, "qc_nanoq", "{sample}_cleanfilt2k_report.txt"
        ),
        assemblyreport=os.path.join(
            output_dir, "qc_nanoq", "{sample}_cleanfilt1k_report.txt"
        ),
    params:
        spp=config["PARAMS"]["NANOQ_SPP"],
        assembly=config["PARAMS"]["NANOQ_ASSEMBLY"],
    threads: 1
    log:
        os.path.join(output_dir_logs, "qc_nanoq", "{sample}_nanoq.out"),
    benchmark:
        os.path.join(output_dir_benchmarks, "qc_nanoq", "{sample}_nanoq_benchmark.out")
    shell:
        """
        (nanoq -i {input} {params.spp} -o {output.spp} -H -r {output.sppreport}
        nanoq -i {input} {params.assembly} -o {output.assembly} -H -r {output.assemblyreport}) &> {log}
        """


# concatenate output of rule remove_host NoHuman statistics from all samples
rule qc_remove_host_stats:
    input:
        logs=expand(
            os.path.join(output_dir_logs, "qc_remove_host", "{sample}_nohuman.out"),
            sample=samples["sample"],
        ),
    output:
        os.path.join(output_dir, "qc_host_removed.tsv"),
    log:
        os.path.join(output_dir_logs, "qc_remove_host_stats", "remove_host_stats.out"),
    shell:
        """
        (grep -H "sequences classified (" {input.logs} | tr -s '[:blank:]' | sed "s#results/logs/qc_nohuman/##g;s#_nohuman\\.out##g;s#: .*(#\t#g;s#%)##g" | sort | sed '1i sample\treads_removed_percent' > {output}) &> {log}
        """


# plot quality metrics for reads at various filtering levels using NanoPlot
rule qc_nanoplot_clean:
    conda:
        "../envs/nanoplot_v1.42.0.yml"
    input:
        raw=get_reads,
        clean=os.path.join(output_dir, "qc_reads", "{sample}_clean.fastq.gz"),
    params:
        format=config["PARAMS"]["NANOPLOTFORMAT"],
        extra=config["PARAMS"]["NANOPLOT"],
    threads: 4
    output:
        raw=directory(os.path.join(output_dir, "qc_nanoplot", "{sample}")),
        clean=directory(os.path.join(output_dir, "qc_nanoplot", "{sample}_clean")),
        cleanreport=os.path.join(
            output_dir, "qc_nanoplot", "{sample}_clean", "NanoStats.txt"
        ),
    log:
        os.path.join(output_dir_logs, "qc_nanoplot", "{sample}_nanoplot_clean.out"),
    benchmark:
        os.path.join(
            output_dir_benchmarks, "qc_nanoplot", "{sample}_nanoplot_benchmark.out"
        )
    shell:
        """
        # remove output folders if they exist
        if [ -d {output.raw} ]; then
            rm -r {output.raw}
        fi

        if [ -d {output.clean} ]; then
            rm -r {output.clean}
        fi

        # run NanoPlot
        (NanoPlot -t {threads} {params.format} {input.raw} -o {output.raw} {params.extra}) &> {log} 
        (NanoPlot -t {threads} {params.format} {input.clean} -o {output.clean} {params.extra}) &> {log} 
        """


# concatenate output of rule nanoplot for all samples
rule qc_read_metrics:
    input:
        cleanreports=expand(
            os.path.join(output_dir, "qc_nanoplot", "{sample}_clean/NanoStats.txt"),
            sample=samples["sample"],
        ),
        onekbreports=expand(
            os.path.join(output_dir, "qc_nanoq", "{sample}_cleanfilt1k_report.txt"),
            sample=samples["sample"],
        ),
        twokbreports=expand(
            os.path.join(output_dir, "qc_nanoq", "{sample}_cleanfilt2k_report.txt"),
            sample=samples["sample"],
        ),
    output:
        clean=os.path.join(output_dir, "qc_read_metrics_clean.tsv"),
        filt=os.path.join(output_dir, "qc_read_metrics_cleanfilt.tsv"),
    log:
        os.path.join(output_dir_logs, "qc_read_metrics", "read_metrics.out"),
    shell:
        """
        # for cleaned reads
        (grep -H "Mean read\\|Median read\\|Number of reads\\|N50\\|Total bases" {input.cleanreports} | tr -s '[:blank:]' |  sed 's#:#\t#g;s#_clean/NanoStats.txt##g;s#qc_nanoplot/##g;s#,##g'  > {output.clean}) &> {log}

        # for 1kb reads
        cat {input.onekbreports} {input.twokbreports}  > filt_temp.txt
        if [[ -s filt_temp.txt ]]; then
                (grep -H "" {input.onekbreports} {input.twokbreports} | sed 's#:#\t#g;s#_cleanfilt#\t#g;s#_report.txt##g;s#qc_nanoq/##g;s# #\t#g' | grep -v "reads" | sed '1i sample\tfiltering\treads\tbases\tn50\tlongest\tshortest\tmean_length\tmedian_length\tmean_quality\tmedian_quality' > {output.filt}) &>> {log}
            else
                touch {output.filt}
        fi
        rm filt_temp.txt
        """


# print a list of samples that failed assembly
rule qc_failed_assemblies:
    input:
        expand(
            os.path.join(output_dir, "assembly_flye", "{sample}_flye.fasta"),
            sample=samples["sample"],
        ),
    output:
        os.path.join(output_dir, "qc_failed_assemblies.txt"),
    threads: 1
    log:
        os.path.join(output_dir_logs, "assembly_failed", "failed_assembly.out"),
    shell:
        """
        for GENOME in results/assembly_flye/*.fasta
        do
            HEADER=$(echo $GENOME | sed 's#_flye.fasta##g;s#results/assembly_flye/##g') 
            if [[ -s $GENOME ]]; then
                touch {output}
            else
                echo $HEADER >> {output}
            fi
        done
        """


# evaluate assembly completeness with CheckM2
rule qc_checkm2:
    conda:
        "../envs/checkm2_v1.0.2.yml"
    input:
        gather_files=aggregate_assembly_input,
    output:
        report=os.path.join(output_dir, "qc_assembly_checkm2.tsv"),
    threads: 8
    params:
        gather_files=lambda wildcards, input: input.gather_files,
        db=config["DATABASES"]["CHECKM2_DB"],
        extra=config["PARAMS"]["CHECKM2"],
    resources:
        mem_mb=10000,
    log:
        os.path.join(output_dir_logs, "qc_checkm2", "checkm2.out"),
    benchmark:
        os.path.join(output_dir_benchmarks, "qc_checmk2", "checkm2_benchmark.out")
    shell:
        """
        cat {params.gather_files} > checkm2_temp.fasta
        
        # if all assemblies are empty/failed:
        if [[ -s checkm2_temp.fasta ]]; then
                (checkm2 predict -t {threads} {params.extra} -i results/assembly_flye --database_path {params.db} -o results/qc_checkm2) &> {log}
                cp results/qc_checkm2/quality_report.tsv {output.report}
            else
                touch {output.report}
        fi

        rm checkm2_temp.fasta
        """


# evaluate assembly coverage with CoverM
rule qc_coverage:
    conda:
        "../envs/coverm_v0.7.0.yml"
    input:
        assembly=os.path.join(output_dir, "assembly_flye", "{sample}_flye.fasta"),
        reads=os.path.join(output_dir, "qc_reads", "{sample}_clean.fastq.gz"),
    output:
        os.path.join(output_dir, "qc_coverm", "{sample}_coverage.tsv"),
    threads: 1
    params:
        extra=config["PARAMS"]["COVERM"],
    log:
        os.path.join(output_dir_logs, "qc_coverm", "{sample}_coverage.out"),
    benchmark:
        os.path.join(
            output_dir_benchmarks, "qc_coverm", "{sample}_coverage_benchmark.out"
        )
    shell:
        """
        # if assemblies is empty/failed:
        if [[ -s {input.assembly} ]]; then
                (coverm genome --single {input.reads} -f {input.assembly} -m {params.extra} -o {output}) &> {log}
            else
                touch {output}
        fi 
        """


# concatenate output of rule coverage CoverM for all samples
rule qc_coverage_concatenate:
    input:
        report=expand(
            os.path.join(output_dir, "qc_coverm", "{sample}_coverage.tsv"),
            sample=samples["sample"],
        ),
    output:
        os.path.join(output_dir, "qc_assembly_coverage.tsv"),
    threads: 1
    log:
        os.path.join(
            output_dir_logs, "qc_coverage_concatenate", "coverage_concatenate.out"
        ),
    shell:
        """
        cat {input.report} | sed 's#Genome.*##g' | awk 'NF' | sort > {output}
        """
