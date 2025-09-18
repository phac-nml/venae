process ASSIGN_ORGANISM_AMR {
    label 'process_quick'

    conda "${moduleDir}/environment.yml"
    container 'oras://community.wave.seqera.io/library/assign_organism_amr:3313c090a1cdb619'

    input:
    path(sylph_profile)
    path(pointfinder_organism)
    val(threshold)
    path(samplelist)

    output:
    path("spp_assigned.tsv"), emit: spp_assigned
    path("spp_fungi_samples.tsv"), emit: fungi
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    assign_organism_amr.py ${threshold} ${samplelist}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        assign_organism_amr: \$( python --version )
    END_VERSIONS
    """

    stub:
    """
    touch spp_assigned.tsv
    touch spp_fungi_samples.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        assign_organism_amr: \$( python --version )
    END_VERSIONS
    """
}
