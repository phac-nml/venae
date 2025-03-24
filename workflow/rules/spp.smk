####################################
#
# Rules for species identification
#
####################################


# based on output from Sylph, get list of species-specific database parameters for AMR detection
checkpoint spp_assign_organism_amr:
    conda:
        "../envs/assign_organism_amr.yml"
    input:
        sylph=os.path.join(output_dir, "spp_sylph_profile.tsv"),
        keystar=os.path.join("resources", "pointfinder_organism.tsv"),
        script=os.path.join("workflow", "scripts", "assign_organism_amr.py"),
    output:
        assigned=os.path.join(output_dir, "spp_assigned.tsv"),
        fungi=os.path.join(output_dir, "spp_fungi_samples.tsv"),
    threads: 1
    params:
        threshold=config["REPORT"]["SPP_DETECTION_PERCENT_THRESHOLD"],
    log:
        os.path.join(output_dir_logs, "spp_assign_organism_amr", "assign_organism.out"),
    benchmark:
        os.path.join(
            output_dir_benchmarks,
            "spp_assign_organism_amr",
            "assign_organism_benchmark.out",
        )
    shell:
        """
        (python {input.script} {params.threshold}) &> {log}
        """


# detect species using Kraken2
rule spp_detection_kraken2:
    conda:
        "../envs/kraken2_v2.1.4.yml"
    input:
        reads=os.path.join(output_dir, "qc_reads", "{sample}_cleanfilt2k.fastq.gz"),
    params:
        db=config["DATABASES"]["KRAKEN2_DB"],
        threshold=config["REPORT"]["SPP_DETECTION_PERCENT_THRESHOLD"],
        extra=config["PARAMS"]["KRAKEN2"],
    threads: 8
    resources:
        mem_mb=16000,
    output:
        report=os.path.join(output_dir, "spp_kraken2", "{sample}_clean_std.kreport"),
        spp=os.path.join(output_dir, "{sample}_spp.tsv"),
    log:
        os.path.join(output_dir_logs, "spp_kraken2", "{sample}_kraken2.out"),
    benchmark:
        os.path.join(
            output_dir_benchmarks, "spp_kraken2", "{sample}_kraken2_benchmark.out"
        )
    shell:
        """
        # run kraken2
        (kraken2 --db {params.db} --threads {threads} --report {output.report} {params.extra} {input.reads}) &> {log}
        
        # assign sample to variable
        sample_id={wildcards.sample}
        
        # summarize output of Kraken2 for top species
        (awk -F"\t" -v var="$sample_id" '($4 == "S" || $4 == "G" || $4 == "O") && $1 > {params.threshold} || $4 == "U" || $4 == "R" || $6 ~ /Homo sapiens/ {{print var"\tkraken2\t"$0}}' \
            {output.report} | tr -s '[:blank:]' | sed 's#_std.kreport:##g;s#\\t #\\t#g' > {output.spp}) &> {log}
        """


# detect species using Sylph
rule spp_sylph_sketch:
    conda:
        "../envs/sylph_v0.8.0.yml"
    input:
        reads=expand(
            os.path.join(output_dir, "qc_reads", "{sample}_cleanfilt2k.fastq.gz"),
            sample=samples["sample"],
        ),
    output:
        report=os.path.join(output_dir, "spp_sylph_profile.tsv"),
        tax=os.path.join(output_dir, "spp_sylph_taxonomy.tsv"),
    log:
        profile=os.path.join(output_dir_logs, "spp_sylph", "sylph_profile.out"),
        tax=os.path.join(output_dir_logs, "spp_sylph", "sylph_tax.out"),
    benchmark:
        os.path.join(output_dir_benchmarks, "spp_sylph", "sylph_benchmark.out")
    params:
        db_bac=config["DATABASES"]["SYLPH_DB_BAC"],
        db_fungi=config["DATABASES"]["SYLPH_DB_FUNGI"],
        tax_bac=config["DATABASES"]["SYLPH_TAX_BAC"],
        tax_fungi=config["DATABASES"]["SYLPH_TAX_FUNGI"],
        sketch=config["PARAMS"]["SYLPH_SKETCH"],
        profile=config["PARAMS"]["SYLPH_PROFILE"],
        tax=config["PARAMS"]["SYLPH_TAX"],
    threads: 8
    resources:
        mem_mb=14000,
    shell:
        """
        # run sketch AND PROFILE
        (sylph sketch -r {input.reads} -t {threads} {params.sketch} -d results/spp_sylph) &> {log.profile}

        # check if *.sylsp files exist
        count=$(find  results/spp_sylph/ -type f -name "*.sylsp" | wc -l)
        if [[ ${{count}} -ne 0 ]]; then

            (sylph profile results/spp_sylph/*.sylsp {params.db_bac} {params.db_fungi} -t {threads} {params.profile} -o results/spp_sylph/profile.tsv) &>> {log.profile}
            cat results/spp_sylph/profile.tsv | sed 's#Sample_file.*##g;s#_cleanfilt2k.fastq.gz##g' | sort > {output.report}

            # remove .sylphmpa files if they exist as cannot force overwrite
            files=$(find  results/spp_sylph/ -type f -name "*.sylphmpa" | wc -l)
            if [[ ${{files}} -ne 0 ]]; then
                rm results/spp_sylph/*.sylphmpa
            fi

            # run taxonomy 
            (sylph-tax taxprof results/spp_sylph/profile.tsv -t {params.tax_bac} {params.tax_fungi} -o results/spp_sylph/ {params.tax}) &> {log.tax}
            grep "" results/spp_sylph/*sylphmpa | sed 's#:#\t##g' | sed 's/.*#SampleID.*//g' | awk 'NF' > {output.tax}
        
        else
            (echo ""
            echo "No samples had enough reads to for sylph profiling. Skipping sylph-tax step which assigns taxonomy.") &>> {log.profile}
            touch {output.report}
            touch {output.tax}
        fi
        """
