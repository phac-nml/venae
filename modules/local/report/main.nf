process GENERATE_REPORT {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container 'oras://community.wave.seqera.io/library/r_env_report:1296ec87ad2c05c5'

    input:
    path(rmd)
    path(samples, stageAs: "samples.tsv")
    path(kraken2_spp_files)
    path(sylph_tax)
    path(reads_clean)
    path(reads_filt)
    path(coverage)
    path(genomesize)
    path(failed)
    path(staramr)
    path(chroquetas)
    path(kmer)
    path(cge_key)
    path(clsi_key)
    path(checkm2)
    path(abricate)
    path(emmtyper)
    path(fungi)
    path(clsi_tables)

    output:
    path("${params.report_name}.html"), emit: report
    path('.command.log'), emit: log, optional: true
    path "versions.yml"                                , emit: versions

    script:
    def kraken2_str = kraken2_spp_files instanceof List ? kraken2_spp_files.join(" ") : kraken2_spp_files
    def clsi_tables_str = clsi_tables instanceof List ? clsi_tables.join(" ") : clsi_tables
    """
    Rscript --vanilla -e 'rmarkdown::render("00_report.Rmd", \
        params=list( \
            hour="${params.timepoint}", \
            runname="${params.run_name}", \
            sppproportion="${params.spp_detection_percent_threshold}", \
            minreadnumqc="${params.spp_min_number_reads_threshold}", \
            minreadqscore="${params.min_read_qcore}", \
            minreadlength="${params.min_median_read_length_bp}", \
            samplenames="samples.tsv", \
            spp="${kraken2_str}", \
            sylph="${sylph_tax}", \
            reads="${reads_clean}", \
            readsfilt="${reads_filt}", \
            coverage="${coverage}", \
            genomesize="${genomesize}", \
            failed="${failed}", \
            staramr="${staramr}", \
            chroquetas="${chroquetas}", \
            kmer="${kmer}", \
            cgekey="${cge_key}", \
            clsikey="${clsi_key}", \
            checkm="${checkm2}", \
            vfdb="${abricate}", \
            emm="${emmtyper}", \
            fungi="${fungi}", \
            clsi="${clsi_tables_str}"),
        output_file = "${params.report_name}.html")'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RMarkdown: \$(Rscript --version)
    END_VERSIONS
    """

    stub:
    def kraken2_str = kraken2_spp_files instanceof List ? kraken2_spp_files.join(" ") : kraken2_spp_files
    def clsi_tables_str = clsi_tables instanceof List ? clsi_tables.join(" ") : clsi_tables
    """
    touch ${params.report_name}.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RMarkdown: \$(Rscript --version)
    END_VERSIONS
    """
}
