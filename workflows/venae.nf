/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'

include { NOHUMAN } from '../modules/local/nohuman/main'
include { NOHUMAN_STATS } from '../modules/local/utils/main'
include { NANOQ as NANOQ_FILT1K } from '../modules/nf-core/nanoq/main'
include { NANOQ as NANOQ_FILT2K} from '../modules/nf-core/nanoq/main'
include { NANOQ_STATS } from '../modules/local/utils/main'
include { NANOPLOT as NANOPLOT_RAW } from '../modules/nf-core/nanoplot/main'
include { NANOPLOT as NANOPLOT_CLEAN } from '../modules/nf-core/nanoplot/main'
include { NANOPLOT_CLEAN_STATS } from '../modules/local/utils/main'
include { FLYE } from '../modules/local/flye/main'
include { COVERM_GENOME } from '../modules/local/coverm/genome/main'
include { COVERM_CONCATENATE } from '../modules/local/utils/main'
include { CHECKM2_PREDICT } from '../modules/local/checkm2/predict/main'
include { KRAKEN2_KRAKEN2 } from '../modules/nf-core/kraken2/kraken2/main'
include { KRAKEN2_SUMMARY } from '../modules/local/utils/main'
include { KRAKEN2_CONCATENATE } from '../modules/local/utils/main'
include { SYLPH_PROFILE } from '../modules/local/sylph/profile/main'
include { SYLPH_SKETCH } from '../modules/local/sylph/sketch/main'
include { SYLPHTAX_TAXPROF } from '../modules/local/sylphtax/taxprof/main'
include { ASSIGN_ORGANISM_AMR } from '../modules/local/assign_organism_amr/main'
include { STARAMR_SEARCH } from '../modules/nf-core/staramr/search/main'
include { STARAMR_CONCATENATE } from '../modules/local/utils/main'
include { CHROQUETAS } from '../modules/local/chroquetas/main'
include { CHROQUETAS_CONCATENATE } from '../modules/local/utils/main'
include { KMERRESISTANCE } from '../modules/local/kmerresistance/main'
include { KMERRESISTANCE_CONCATENATE } from '../modules/local/utils/main'
include { ABRICATE_RUN } from '../modules/nf-core/abricate/run/main'
include { ABRICATE_CONCATENATE } from '../modules/local/utils/main'
include { EMMTYPER } from '../modules/local/emmtyper/main'
include { EMMTYPER_CONCATENATE } from '../modules/local/utils/main'
include { GENERATE_REPORT } from '../modules/local/report/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INITIALIZE CHANNELS FROM PARAMS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
ch_nohuman_db                       = file(params.nohuman_db, checkIfExists: true)
ch_checkm2_db                       = file(params.checkm2_db, checkIfExists: true)
ch_kraken2_db                       = file(params.kraken2_db, checkIfExists: true)
ch_sylph_db_bac                     = file(params.sylph_db_bac, checkIfExists: true)
ch_sylph_db_fungi                   = file(params.sylph_db_fungi, checkIfExists: true)
ch_sylph_tax_bac                    = file(params.sylph_tax_bac, checkIfExists: true)
ch_sylph_tax_fungi                  = file(params.sylph_tax_fungi, checkIfExists: true)

ch_kmerresistance_db_dir            = file(params.kmerresistance_db_arg).parent
ch_kmerresistance_db_arg_name       = file(params.kmerresistance_db_arg).name
ch_kmerresistance_db_spp_name       = file(params.kmerresistance_db_spp).name
ch_pointfinder_orgs                 = file(params.pointfinder_orgs, checkIfExists: true)
ch_chroquetas_orgs                 = file(params.chroquetas_orgs, checkIfExists: true)
ch_emmtyper_db_dir                  = file(params.emmtyper_db).parent
ch_emmtyper_db_name                 = file(params.emmtyper_db).name

ch_clsi_tables                      = files(params.clsi_tables, checkIfExists: true)
ch_rmd                              = files("${projectDir}/bin/*.R*", checkIfExists: true)
ch_genomesize                       = file(params.genomesize_key, checkIfExists: true)
ch_cge                              = file(params.cge_key, checkIfExists: true)
ch_clsi                             = file(params.clsi_key, checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow VENAE {

    take:
    ch_samplesheet // channel: samplesheet read in from --input
    main:

    ch_versions = Channel.empty()

    // //
    // // MODULE: Run NoHuman to remove host reads
    // //
    NOHUMAN(ch_samplesheet, ch_nohuman_db)
    ch_versions = ch_versions.mix(NOHUMAN.out.versions.first())

    // Concatenate removed host read stats
    NOHUMAN_STATS(NOHUMAN.out.log.collect())

    // //
    // // MODULE: Run Nanoq to filter long reads for assembly and species ID
    // //
    NANOQ_FILT2K(NOHUMAN.out.reads, "fastq.gz")
    ch_versions = ch_versions.mix(NANOQ_FILT2K.out.versions.first())

    NANOQ_FILT1K(NOHUMAN.out.reads, "fastq.gz")

    // Concatenate filtered read stats
    NANOQ_FILT1K.out.stats
        .map{ meta, stats -> stats }
        .collect()
        .set { ch_nanoq_filt1k_stats }
    NANOQ_FILT2K.out.stats
        .map{ meta, stats -> stats }
        .collect()
        .set { ch_nanoq_filt2k_stats }
    NANOQ_STATS(ch_nanoq_filt1k_stats, ch_nanoq_filt2k_stats)

    // //
    // // MODULE: Run NanoPlot to output read statistics
    // //
    NANOPLOT_RAW(ch_samplesheet)
    ch_versions = ch_versions.mix(NANOPLOT_RAW.out.versions.first())

    NANOPLOT_CLEAN(NOHUMAN.out.reads)

    // Concatenate read statistics for clean reads
    NANOPLOT_CLEAN.out.txt
        .map{ meta, stats -> stats }
        .collect()
        .set { ch_nanoplot_clean_stats }

    NANOPLOT_CLEAN_STATS(ch_nanoplot_clean_stats)

    //
    // MODULE: Run Flye to generate assemblies
    //
    FLYE(NANOQ_FILT1K.out.reads, params.flye_mode)
    ch_versions = ch_versions.mix(FLYE.out.versions.first())

    // Print list of failed assemblies based on assembly fasta size
    ch_assemblies = FLYE.out.fasta
        .branch { meta, fasta ->
                    pass: fasta.size() > 0
                    fail: fasta.size () == 0
                    unknown: true
                    }
        .set {ch_assembly_status}

    ch_assembly_status.pass.view { v -> "$v has passed assembly"}
    ch_assembly_status.fail.view { v -> "$v has failed assembly"}

    ch_assembly_status.fail
        .map {meta, fasta -> meta.id}
        .collectFile(name: "qc_failed_assemblies.txt", newLine: true, storeDir: params.outdir)
        .set {ch_assembly_failed}

    // //
    // // MODULE: Run CoverM to output actual coverage for each completed assembly
    // //
    ch_reads_genome = NOHUMAN.out.reads
        .join(ch_assembly_status.pass)
    COVERM_GENOME(ch_reads_genome)
    ch_versions = ch_versions.mix(COVERM_GENOME.out.versions.first())

    // Concatenate coverage reports
    COVERM_GENOME.out.report
        .map{ meta, report -> report }
        .collect()
        .set { ch_coverm_report }
    COVERM_CONCATENATE(ch_coverm_report)

    // //
    // // MODULE: Run CheckM2 to output assembly completeness
    // //
    ch_assembly_status.pass
        .map {sample, assembly -> file(assembly)}
        .collect()
        .set {ch_assembly_pass_concat}
    CHECKM2_PREDICT(ch_assembly_pass_concat, ch_checkm2_db)
    ch_versions = ch_versions.mix(CHECKM2_PREDICT.out.versions)

    // //
    // // MODULE: Run Kraken2 for preliminary species ID
    // //
    KRAKEN2_KRAKEN2(NANOQ_FILT2K.out.reads, ch_kraken2_db, params.kraken2_save_output_fastqs, params.kraken2_save_reads_assignment)
    ch_versions = ch_versions.mix(KRAKEN2_KRAKEN2.out.versions.first())

    KRAKEN2_SUMMARY(KRAKEN2_KRAKEN2.out.report, params.spp_detection_percent_threshold)

    KRAKEN2_SUMMARY.out.kraken2
        .collect()
        .set { ch_kraken2_report }
    KRAKEN2_CONCATENATE(ch_kraken2_report)

    // //
    // // MODULE: Run sylph sketch and profile for species ID
    // //
    SYLPH_SKETCH(NANOQ_FILT2K.out.reads)
    ch_versions = ch_versions.mix(SYLPH_SKETCH.out.versions.first())

    SYLPH_SKETCH.out.sketch_fastq_genome
        .map { sample, sketch -> file(sketch)}
        .collect()
        .set {ch_sylph_sketch_concat}

    SYLPH_PROFILE(ch_sylph_sketch_concat, ch_sylph_db_bac, ch_sylph_db_fungi)
    ch_versions = ch_versions.mix(SYLPH_PROFILE.out.versions)

    // //
    // // MODULE: Run sylph-tax for taxonomy assignment
    // //
    SYLPHTAX_TAXPROF(SYLPH_PROFILE.out.profile_out, ch_sylph_tax_bac, ch_sylph_tax_fungi)
    ch_versions = ch_versions.mix(SYLPHTAX_TAXPROF.out.versions)

    // //
    // // MODULE: Run python script to assign organism parameter for AMR tools
    // //
    ASSIGN_ORGANISM_AMR(SYLPH_PROFILE.out.profile_out, ch_pointfinder_orgs, ch_chroquetas_orgs, params.spp_detection_percent_threshold, file(params.input))
    ch_versions = ch_versions.mix(ASSIGN_ORGANISM_AMR.out.versions)

    // Get list of samples that passed assembly
    ASSIGN_ORGANISM_AMR.out.spp_assigned
                    .splitCsv(header: true, sep: '\t')
                    //.view { v -> "$v is csv"}
                    .map { row -> tuple(row.sample, row.spp_ID, row.pointfinder_organism, row.chroquetas_organism) }
                    //.view { v -> "$v is mapped"}
                    .set { ch_species_pointfinder }

    // re-map passed assembly channel for easier joining
    ch_assembly_status.pass
                    .map { meta, assembly -> [meta.id, meta, assembly]}
                    .set { ch_assemblies_passed }

    // join list of samples that passed assembly to pointfinder organism by sample/meta.id
    ch_species_pointfinder
                    .join(ch_assemblies_passed)
                    //.view { v -> "$v is joined"}
                    .map { sample, spp_ID, org, org2, meta, assembly -> [meta, spp_ID, org, org2, assembly] }
                    //.view { v -> "$v is mapped again"}
                    .set {ch_sample_spp_assigned}

    // Get channels of samples for specific organism typing
    ch_sample_spp_assigned
                    .branch { sample, spp, pointfinder_organism, chroquetas_organism, assembly ->
                            staph: spp.contains("Staphylococcus aureus")
                                return tuple(sample, assembly)
                            strep: spp.contains("Streptococcus pyogenes")
                                return tuple(sample, assembly)
                            other: true
                                return tuple(sample, assembly)
                        }
                    .set{ch_typing}

    ch_typing.staph.view { v -> "$v is Staphylococcus aureus"}
    ch_typing.strep.view { v -> "$v is Streptococcus pyogenes"}

    // Get channel for fungi samples that passed assembly
    ch_sample_spp_assigned
                    .branch { sample, spp, pointfinder_organism, chroquetas_organism, assembly ->
                            // if chroquetas_organism exists
                            fungi: chroquetas_organism
                                return tuple(sample, assembly, chroquetas_organism)}
                    .set{ch_spp_fungi}
    ch_spp_fungi.fungi.view { v -> "$v is fungi"}

    // Get channel for bacteria samples that passed assembly
    ch_sample_spp_assigned
                    .branch { sample, spp, pointfinder_organism, chroquetas_organism, assembly ->
                            // if pointfinder_organism exists or if there is no chroquetas_organism
                            bacteria: pointfinder_organism || !chroquetas_organism
                                return tuple(sample, assembly, pointfinder_organism)}
                    .set{ch_spp_bacteria}
    ch_spp_bacteria.bacteria.view { v -> "$v is bacteria"}

    // //
    // // MODULE: Run emmtyper for Streptococcus pyogenes typing
    // //
    EMMTYPER(ch_typing.strep, ch_emmtyper_db_dir, ch_emmtyper_db_name)
    ch_versions = ch_versions.mix(EMMTYPER.out.versions)

    // Concatenate Streptococcus pyogenes typing reports
    EMMTYPER.out.tsv
        .map{ meta, report -> report }
        .collect()
        .set { ch_emmtyper_report }
    EMMTYPER_CONCATENATE(ch_emmtyper_report)

    // //
    // // MODULE: Run ABRicate for Staphylococcus aureus typing
    // //
    ABRICATE_RUN(ch_typing.staph, params.abricate_databasedir)
    ch_versions = ch_versions.mix(ABRICATE_RUN.out.versions)

    // Concatenate Staphylococcus aureus typing reports
    ABRICATE_RUN.out.report
        .map{ meta, report -> report }
        .collect()
        .set { ch_abricate_report }
    ABRICATE_CONCATENATE(ch_abricate_report)

    // //
    // // MODULE: Run KmerResistance for read-based AMR detection
    // //
    KMERRESISTANCE(NOHUMAN.out.reads,
                        ch_kmerresistance_db_dir,
                        ch_kmerresistance_db_arg_name,
                        ch_kmerresistance_db_spp_name)
    ch_versions = ch_versions.mix(KMERRESISTANCE.out.versions)

    // Concatenate AMR detection with KmerResistance reports
    KMERRESISTANCE.out.report
        .map{ meta, report -> report }
        .collect()
        .set { ch_kmerresistance_report }
    KMERRESISTANCE_CONCATENATE(ch_kmerresistance_report)

    //
    // MODULE: Run StarAMR for assembly-based AMR detection
    //
    STARAMR_SEARCH(ch_spp_bacteria.bacteria)
    ch_versions = ch_versions.mix(STARAMR_SEARCH.out.versions)

    // Concatenate AMR detection with KmerResistance reports
    STARAMR_SEARCH.out.detailed_summary_tsv
        .map{ meta, report -> report }
        .collect()
        .set { ch_staramr_report }
    STARAMR_CONCATENATE(ch_staramr_report)

    //
    // MODULE: Run ChroQueTas for fungi assembly-based AMR
    //
    CHROQUETAS(ch_spp_fungi.fungi)
    ch_versions = ch_versions.mix(CHROQUETAS.out.versions)

    // Concatenate AMR detection with KmerResistance reports
    CHROQUETAS.out.summary_txt
        .map{ meta, report -> report }
        .collect()
        .set { ch_chroquetas_report }
    CHROQUETAS_CONCATENATE(ch_chroquetas_report)

    //
    // MODULE: Generate output report summarizing all results
    //

    // Channels for processes that may not have run or failed for GENERATE_REPORT input
    ch_failed_assemblies = ch_assembly_failed.ifEmpty(file(params.no_failed))
    ch_sylph = SYLPHTAX_TAXPROF.out.taxprof_output.ifEmpty(file(params.no_sylph))
    ch_reads_filt =  NANOQ_STATS.out.report.ifEmpty(file(params.no_reads_filt))
    ch_checkm = CHECKM2_PREDICT.out.checkm2_tsv.ifEmpty(file(params.no_checkm))
    ch_coverage = COVERM_CONCATENATE.out.report.ifEmpty(file(params.no_coverage))
    ch_staph = ABRICATE_CONCATENATE.out.report.ifEmpty(file(params.no_staph))
    ch_strep = EMMTYPER_CONCATENATE.out.report.ifEmpty(file(params.no_strep))
    ch_staramr = STARAMR_CONCATENATE.out.report.ifEmpty(file(params.no_staramr))
    ch_chroquetas = CHROQUETAS_CONCATENATE.out.report.ifEmpty(file(params.no_chroquetas))
    ch_kmerres = KMERRESISTANCE_CONCATENATE.out.report.ifEmpty(file(params.no_kmerres))

    GENERATE_REPORT(
        ch_rmd,
        file(params.input),
        KRAKEN2_CONCATENATE.out.report,
        ch_sylph,
        NANOPLOT_CLEAN_STATS.out.report,
        ch_reads_filt,
        ch_coverage,
        ch_genomesize,
        ch_failed_assemblies,
        ch_staramr,
        ch_chroquetas,
        ch_kmerres,
        ch_cge,
        ch_clsi,
        ch_checkm,
        ch_staph,
        ch_strep,
        ASSIGN_ORGANISM_AMR.out.fungi,
        ch_clsi_tables)
    ch_versions = ch_versions.mix(GENERATE_REPORT.out.versions)

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name:  'venae_software_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    emit:
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
