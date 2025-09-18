process SYLPH_PROFILE {
    label 'process_medium'
    label 'error_ignore'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sylph:0.8.1--ha6fb395_0' :
        'biocontainers/sylph:0.8.1--ha6fb395_0' }"

    input:
    path(sketch)
    path(db_bac)
    path(db_fungi)

    output:
    path("profile.tsv"), emit: profile_out, optional: true
    path "versions.yml"           , emit: versions
    path('.command.log'), emit: log

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    sylph profile \\
        -t $task.cpus \\
        $args \\
        $db_bac \\
        $db_fungi \\
        *.sylsp \\
        -o profile.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sylph: \$(sylph -V | awk '{print \$2}')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch profile.tsv
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sylph: \$(sylph -V | awk '{print \$2}')
    END_VERSIONS
    """

}
