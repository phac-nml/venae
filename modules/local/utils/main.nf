/*
 * Concatenate removed host read stats into a single file
 */

process NOHUMAN_STATS {
    label 'process_quick'

    input:
    path(logs)

    output:
    path("qc_host_removed.tsv"), emit: report

    script:
    def input_str = logs instanceof List ? logs.join(" ") : logs
    """
    grep -H "sequences classified (" ${input_str} | \
        tr -s '[:blank:]' | \
        sed "s#.*logs/nohuman/##g;s#_clean.out##g;s#: .*(#\t#g;s#%)##g" | \
        sort | \
        sed '1i sample\treads_removed_percent' > "qc_host_removed.tsv"
    """
}

/*
 * Summarize clean read statistics from all samples into a single file
 */

process NANOPLOT_CLEAN_STATS {
    label 'process_quick'

    input:
    path(clean_stats)

    output:
    path("qc_read_metrics_clean.tsv"), emit: report

    script:
    def input_str = clean_stats instanceof List ? clean_stats.join(" ") : clean_stats
    """
    # for cleaned reads
    grep -H "mean_\\|median_\\|number_of_reads\\|n50\\|number_of_bases" ${input_str} | tr -s '[:blank:]' |  sed 's#:#\t#g;s#_NanoStats.txt##g'  > qc_read_metrics_clean.tsv
    """
}

/*
 * Summarize filtered read statistics from all samples into a single file
 */

process NANOQ_STATS {
    label 'process_quick'

    input:
    path(stats_filt1k)
    path(stats_filt2k)

    output:
    path("qc_read_metrics_cleanfilt.tsv"), emit: report

    script:
    def input_str_filt1k = stats_filt1k instanceof List ? stats_filt1k.join(" ") : stats_filt1k
    def input_str_filt2k = stats_filt2k instanceof List ? stats_filt2k.join(" ") : stats_filt2k
    """
    # for filtered reads
    cat ${input_str_filt1k} ${input_str_filt2k}  > filt_temp.txt
    if [[ -s filt_temp.txt ]]; then
            grep -H "" ${input_str_filt1k} ${input_str_filt2k} | sed 's#:#\t#g;s#_filt#\t#g;s#.stats##g;s#qc_nanoq/##g;s# #\t#g' | grep -v "reads" | sed '1i sample\tfiltering\treads\tbases\tn50\tlongest\tshortest\tmean_length\tmedian_length\tmean_quality\tmedian_quality' > "qc_read_metrics_cleanfilt.tsv"
        else
            touch "qc_read_metrics_cleanfilt.tsv"
    fi
    rm filt_temp.txt
    """
}

/*
 * Concatenate coverage statistics from all samples into a single file
 */

process COVERM_CONCATENATE {
    label 'process_quick'

    input:
    path(report)

    output:
    path("qc_assembly_coverage.tsv"), emit: report

    script:
    def input_str = report instanceof List ? report.join(" ") : report
    """
    cat ${input_str} | sed 's#Genome.*##g' | awk 'NF' | sort > qc_assembly_coverage.tsv
    """
}

/*
 * Summarize output of Kraken2 for top species
 */

process KRAKEN2_SUMMARY {
    label 'process_quick'

    input:
    tuple val(meta), path(report)
    val(threshold)

    output:
    path("${meta.id}_spp.tsv"), emit: kraken2

    script:
    """
    awk -F"\t" -v var="${meta.id}" '(\$4 == "S" || \$4 == "G" || \$4 == "O") && \$1 > ${threshold} || \$4 == "U" || \$4 == "R" || \$6 ~ /Homo sapiens/ {{print var"\tkraken2\t"\$0}}' \
            ${meta.id}.kraken2.report.txt | tr -s '[:blank:]' | sed 's#_std.kreport:##g;s#\\t #\\t#g' > ${meta.id}_spp.tsv
    """
}

/*
 * Concatenate Kraken2 summary spp reports from all samples into a single file
 */

process KRAKEN2_CONCATENATE {
    label 'process_quick'

    input:
    path(reports)

    output:
    path("spp_kraken2_classification.tsv"), emit: report

    script:
        def input_str = reports instanceof List ? reports.join(" ") : reports
        """
        cat ${input_str} > spp_kraken2_classification.tsv
        """
}

/*
 * Concatenate Streptococcus pyogenes emm typing results from all samples into a single file
 */

process EMMTYPER_CONCATENATE {
    label 'process_quick'

    input:
        path(reports)

    output:
        path("typing_strep_pyo_emm.tsv"), emit: report

    script:
        def input_str = reports instanceof List ? reports.join(" ") : reports
        """
        cat ${input_str} > typing_strep_pyo_emm.tsv
        """
}

/*
 * Concatenate Staphylococcus aureus toxin typing results from all samples into a single file
 */

process ABRICATE_CONCATENATE {
    label 'process_quick'

    input:
        path(reports)

    output:
        path("typing_staph_aureus_toxins.tsv"), emit: report

    script:
        def input_str = reports instanceof List ? reports.join(" ") : reports
        """
        cat ${input_str} | sed 's/#FILE.*//g' | awk 'NF' > typing_staph_aureus_toxins.tsv
        """
}

/*
 * Concatenate KmerResistance AMR results from all samples into a single file
 */

process KMERRESISTANCE_CONCATENATE {
    label 'process_quick'

    input:
        path(reports)

    output:
        path("amr_kmerresistance_summary.tsv"), emit: report

    script:
        def input_str = reports instanceof List ? reports.join(" ") : reports
        """
        grep -H "" ${input_str} | sed 's#.*Score.*##g;s#.KmerRes:#\t#g;s#*NC_007795*##g' | awk 'NF' | sort > amr_kmerresistance_summary.tsv
        """
}

/*
 * Concatenate StarAMR AMR results from all samples into a single file
 */

process STARAMR_CONCATENATE {
    label 'process_quick'

    input:
        path(reports, stageAs: "???")

    output:
        path("amr_staramr_detailed_summary.tsv"), emit: report

    script:
        def input_str = reports instanceof List ? reports.join(" ") : reports
        """
        cat ${input_str} | sed 's#^Isolate.*##g' | awk 'NF' > amr_staramr_detailed_summary.tsv
        """
}
