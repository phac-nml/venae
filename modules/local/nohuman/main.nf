process NOHUMAN {
    tag "$meta.id"
    label 'process_cpus'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nohuman:0.3.0--hc1c3326_1' :
        'biocontainers/nohuman:0.3.0--hc1c3326_1'}"

    input:
    tuple val(meta), path(ontreads)
    path(nohuman_db)

    output:
    tuple val(meta), path("*fastq.gz"), emit: reads
    path('*.out'), emit: log
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_clean"
    """
    nohuman -o ${prefix}.fastq.gz \\
        --db ${nohuman_db} \\
        --threads ${task.cpus} \\
        ${args} \\
        ${ontreads} &> ${prefix}.out

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nohuman: \$(nohuman --version | sed -e 's/nohuman //g')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_clean"
    """
    echo "" | gzip > ${prefix}.fastq.gz
    touch ${prefix}.out

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nohuman: \$(nohuman --version | sed -e 's/nohuman //g')
    END_VERSIONS
    """
}
