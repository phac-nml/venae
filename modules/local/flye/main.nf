process FLYE {
    tag "$meta.id"
    label 'process_cpus'
    label 'error_ignore'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/fa/fa1c1e961de38d24cf36c424a8f4a9920ddd07b63fdb4cfa51c9e3a593c3c979/data' :
        'community.wave.seqera.io/library/flye:2.9.5--d577924c8416ccd8' }"

    input:
    tuple val(meta), path(reads)
    val mode

    output:
    tuple val(meta), path("*.fasta"), emit: fasta
    tuple val(meta), path("*.gfa")  , emit: gfa, optional: true
    tuple val(meta), path("*.gv.gz")   , emit: gv, optional: true
    tuple val(meta), path("*.txt")     , emit: txt, optional: true
    tuple val(meta), path("*.log")     , emit: log
    tuple val(meta), path("*.json")    , emit: json
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def valid_mode = ["--pacbio-raw", "--pacbio-corr", "--pacbio-hifi", "--nano-raw", "--nano-corr", "--nano-hq"]
    if ( !valid_mode.contains(mode) )  { error "Unrecognised mode to run Flye. Options: ${valid_mode.join(', ')}" }
    """
    flye \\
        $mode \\
        $reads \\
        --out-dir . \\
        --threads \\
        $task.cpus \\
        $args

    touch assembly.fasta
    mv assembly.fasta ${prefix}_assembly.fasta
    mv assembly_graph.gfa ${prefix}_assembly.gfa
    gzip -c assembly_graph.gv > ${prefix}_assembly.gv.gz
    mv assembly_info.txt ${prefix}_assembly_info.txt
    mv flye.log ${prefix}.flye.log
    mv params.json ${prefix}.params.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        flye: \$( flye --version )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo stub > ${prefix}_assembly.fasta
    echo stub > ${prefix}_assembly.gfa
    echo stub | gzip -c > ${prefix}_assembly_graph.gz
    echo contig_1 > ${prefix}.assembly_info.txt
    echo stub > ${prefix}.flye.log
    echo stub > ${prefix}.params.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        flye: \$( flye --version )
    END_VERSIONS
    """
}
