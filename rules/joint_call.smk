

rule gatk_GenomicsDBImport:
    input:
        gvcfs=expand("variant_calling/{sample.sample}.{{interval}}.g.vcf.gz",
                     sample=samples.reset_index().itertuples())
    output:
        touch("db/imports/{interval}")
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=2),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta")),
        gvcfs=_multi_flag_dbi("-V", expand("variant_calling/{sample.sample}.{{interval}}.g.vcf.gz",
                     sample=samples.reset_index().itertuples()))

    log:
        "logs/gatk/GenomicsDBImport/{interval}.info.log"
    conda:
       "../envs/gatk.yaml"
    benchmark:
        "benchmarks/gatk/GenomicsDBImport/{interval}.txt"
    shell:
        "mkdir -p db; "
        "gatk GenomicsDBImport --java-options {params.custom} "
        "{params.gvcfs} "
        "--genomicsdb-workspace-path db/{wildcards.interval} "
        "-L split/{wildcards.interval}-scattered.interval_list "
        ">& {log} "

rule gatk_GenotypeGVCFs:
    input:
        "db/imports/{interval}"
    output:
        protected("variant_calling/all.{interval}.vcf.gz")
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=2),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta"))
    log:
        "logs/gatk/GenotypeGVCFs/all.{interval}.info.log"
    benchmark:
        "benchmarks/gatk/GenotypeGVCFs/all.{interval}.txt"
    shell:
        "gatk GenotypeGVCFs --java-options {params.custom} "
        "-R {params.genome} "
        "-V gendb://db/{wildcards.interval} "
        "-G StandardAnnotation "
        "-O {output} "
        ">& {log} "