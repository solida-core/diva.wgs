rule gatk_SplitIntervals:
    output:
        touch('split/splitted')
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=1),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta")),
        count=config.get("rules").get("gatk_SplitIntervals").get("scatter-count"),
        mode=config.get("rules").get("gatk_SplitIntervals").get("mode"),
        intervals=config.get("rules").get("gatk_SplitIntervals").get("intervals")
    log:
        "logs/gatk/SplitIntervals/split.log"
    benchmark:
        "benchmarks/gatk/SplitIntervals/split.txt"
    shell:
        "gatk SplitIntervals --java-options {params.custom} "
        "-R {params.genome} "
        "-L {params.intervals} "
        "-mode {params.mode} "
        "--scatter-count {params.count} "
        "-O split "
        ">& {log} "

rule gatk_HaplotypeCaller_ERC_GVCF:
    input:
        'split/splitted',
        bam="reads/recalibrated/{sample}.dedup.recal.bam"

    output:
        gvcf="variant_calling/{sample}.{interval}.g.vcf.gz"
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=2),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta"))
    log:
        "logs/gatk/HaplotypeCaller/{sample}.{interval}.genotype_info.log"
    benchmark:
        "benchmarks/gatk/HaplotypeCaller/{sample}.{interval}.txt"
    shell:
        "gatk HaplotypeCaller --java-options {params.custom} "
        "-R {params.genome} "
        "-I {input.bam} "
        "-O {output.gvcf} "
        "-ERC GVCF "
        "-G StandardAnnotation "
        "-L split/{wildcards.interval}-scattered.interval_list "
        ">& {log} "