
process SYLPHTAX_TAXPROF {
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sylph-tax:1.2.0--pyhdfd78af_0':
        'biocontainers/sylph-tax:1.2.0--pyhdfd78af_0' }"

    input:
    path(profile)
    path(tax_bac)
    path(tax_fungi)

    output:
    path("taxonomy.tsv"), emit: taxprof_output, optional: true
    path "versions.yml"                , emit: versions
    path('.command.log'), emit: log

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    export SYLPH_TAXONOMY_CONFIG="/tmp/config.json"
    sylph-tax \\
        taxprof \\
        $profile \\
        $args \\
        -t $tax_bac $tax_fungi

    grep "" *sylphmpa | sed 's#:#\t##g' | sed 's/.*#SampleID.*//g' | awk 'NF' > taxonomy.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sylph-tax: \$(sylph-tax --version)
    END_VERSIONS
    """

    stub:
    """
    export SYLPH_TAXONOMY_CONFIG="/tmp/config.json"
    touch taxonomy.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sylph-tax: \$(sylph-tax --version)
    END_VERSIONS
    """
}
