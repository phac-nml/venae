process CHECKM2_PREDICT {
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/0a/0af812c983aeffc99c0fca9ed2c910816b2ddb9a9d0dcad7b87dab0c9c08a16f/data':
        'community.wave.seqera.io/library/checkm2:1.1.0--60f287bc25d7a10d' }"

    input:
    path(fasta)
    path(db)

    output:
    path("qc_assembly_checkm2.tsv")                   , emit: checkm2_tsv
    path("versions.yml")                                 , emit: versions
    path('.command.log'), emit: log

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    checkm2 \\
        predict \\
        -t ${task.cpus} \\
        ${args} \\
        --input . \\
        --output-directory qc_checkm2 \\
        --threads ${task.cpus} \\
        --database_path ${db}

    cp qc_checkm2/quality_report.tsv qc_assembly_checkm2.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkm2: \$(checkm2 --version)
    END_VERSIONS
    """

    stub:
    """
    touch qc_assembly_checkm2.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkm2: \$(checkm2 --version)
    END_VERSIONS
    """
}
