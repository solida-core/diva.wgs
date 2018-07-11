def get_known_sites(known_sites=['dbsnp','mills','ph1_indel']):
    known_variants = config.get("known_variants")
    ks = []
    if len(known_sites) == 0:
        known_sites = known_variants.keys()
    for k, v in known_variants.items():
        if k in known_sites:
            ks.append("--knownSites {} ".format(resolve_single_filepath(*references_abs_path(), v)))
    return "".join(ks)


rule gatk_BQSR_data_processing:
    input:
        bam="reads/dedup/{sample}.dedup.bam"
    output:
        "reads/recalibrated/{sample}.recalibrate.grp"
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=4),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta")),
        known_sites=get_known_sites(config.get("rules").get("gatk_BQSR").get("known_sites"))
    log:
        "logs/gatk/BaseRecalibratorSpark/{sample}_BQSR_data_processing_info.log"
    benchmark:
        "benchmarks/gatk/BaseRecalibratorSpark/{sample}_BaseRecalibrator_data_processing_info.txt"
    threads: conservative_cpu_count(reserve_cores=2, max_cores=99)
    shell:
        "gatk BaseRecalibratorSpark --java-options {params.custom} "
        "-R {params.genome} "
        "{params.known_sites} "
        "--spark-runner LOCAL "
        "--spark-master local[{threads}]  "
        "-I {input.bam} "
        "-O {output} {log}"


rule gatk_ApplyBQSR:
    input:
        bam="reads/dedup/{sample}.dedup.bam",
        bqsr="reads/recalibrated/{sample}.recalibrate.grp"
    output:
        temp("reads/recalibrated/{sample}.dedup.recal.bam")
    params:
        custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=4),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta")),
        known_sites=get_known_sites(config.get("rules").get("gatk_BQSR").get("known_sites"))
    log:
        "logs/gatk/ApplyBQSRSpark/{sample}.post_recalibrate_info.log"
    benchmark:
        "benchmarks/gatk/ApplyBQSRSpark/{sample}.post_recalibrate_info.txt"
    threads: conservative_cpu_count(reserve_cores=2, max_cores=99)
    shell:
        "gatk ApplyBQSRSpark --java-options {params.custom} "
        "-R {params.genome} "
        "--spark-runner LOCAL "
        "--spark-master local[{threads}]  "
        "-I {input.bam} "
        "--bqsr-recal-file {input.bqsr} "
        "-O {output} {log} "




rule gatk_BQSR_quality_control:
    input:
        bam="reads/recalibrated/{sample}.dedup.recal.bam",
        pre="reads/recalibrated/{sample}.recalibrate.grp"
    output:
        post="reads/recalibrated/{sample}.post.recalibrate.grp",
        plot="reads/recalibrated/{sample}.recalibration_plots.pdf"
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=4),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta")),
        known_sites=get_known_sites(config.get("rules").get("gatk_BQSR").get("known_sites"))
    log:
        "logs/gatk/BaseRecalibratorSpark/{sample}_BQSR_quality_control_info.log"
    benchmark:
        "benchmarks/gatk/BaseRecalibratorSpark/{sample}_BQSR_quality_control_info.txt"
    threads: conservative_cpu_count(reserve_cores=2, max_cores=99)
    shell:
        "gatk BaseRecalibratorSpark --java-options {params.custom} "
        "-R {params.genome} "
        "{params.known_sites} "
        "--spark-runner LOCAL "
        "--spark-master local[{threads}]  "
        "-I {input.bam} "
        "-O {output} {log}; "
        "gatk AnalyzeCovariates --java-options {params.custom} "
        "-before {input.pre} -after {output.post} -plots {output.plot} {log} "
