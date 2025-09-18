process CHROQUETAS {
    tag "$meta.id"
    label 'process_single'
    label 'error_ignore'


    conda "${moduleDir}/environment.yml"
    container "oras://community.wave.seqera.io/library/chroquetas_v1.0.0:be80203e64c9db30"

    input:
    tuple val(meta), path(genome_fasta), val(organism)

    output:
    tuple val(meta), path("*_results/*ChroQueTaS.AMR_summary.txt"), emit: summary_txt, optional: true
    path "versions.yml"                                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def org = organism ? "-s ${organism}" : ""
    """
    ChroQueTas.sh -g ${genome_fasta} ${org} -o ${prefix}_results -t ${task.cpus}

    touch ${prefix}_results/${prefix}.ChroQueTaS.AMR_summary.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ChroQueTas : \$(echo \$(ChroQueTas.sh --version) | sed 's/^.*version //' )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir ${prefix}_results
    touch ${prefix}_results/${prefix}.ChroQueTaS.AMR_summary.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ChroQueTas : \$(echo \$(ChroQueTas.sh --version) | sed 's/^.*version //' )
    END_VERSIONS
    """
}
