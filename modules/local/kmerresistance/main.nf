process KMERRESISTANCE {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "oras://community.wave.seqera.io/library/kmerresistance_v2.2.0:0829ef34cbe1279c"

    input:
    tuple val(meta), path(ontreads)
    path(db_dir)
    val(db_arg_name)
    val(db_spp_name)

    output:
    tuple val(meta), path("*.KmerRes"), emit: report
    path('.command.log'), emit: log
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    kmerresistance -i ${ontreads} \\
        -o ${prefix} \\
        -t_db ${db_dir}/${db_arg_name} \\
        -s_db ${db_dir}/${db_spp_name} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kmerresistance: \$(kmerresistance -v 2>&1 >/dev/null | sed -e 's/KmerResistance-//g')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_clean"
    """
    touch ${prefix}.KmerRes

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kmerresistance: \$(kmerresistance -v 2>&1 >/dev/null | sed -e 's/KmerResistance-//g')
    END_VERSIONS
    """
}
