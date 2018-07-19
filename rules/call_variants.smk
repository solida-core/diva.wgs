
rule gatk_HaplotypeCaller_ERC_GVCF:
    input:
        bam="reads/recalibrated/{sample}.dedup.recal.bam"
    output:
        gvcf="variant_calling/{sample}.{chr}.g.vcf"
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=4),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta"))
    log:
        "logs/gatk/HaplotypeCaller/{sample}.{chr}.genotype_info.log"
    benchmark:
        "benchmarks/gatk/HaplotypeCaller/{sample}.{chr}.txt"
    threads: 2
    shell:
        "gatk HaplotypeCaller --java-options {params.custom} "
        "-R {params.genome} "
        "-I {input.bam} "
        "-O {output.gvcf} "
        "-ERC GVCF "
        "-L {wildcards.chr} "
        ">& {log} "