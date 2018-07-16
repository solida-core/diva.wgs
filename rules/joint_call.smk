rule gatk_GenomicsDBImport:
    input:
        gvcfs=expand("variant_calling/{sample.sample}.g.vcf",
                     sample=samples.reset_index().itertuples())
    output:
        temp("variant_calling/{chr}")
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=4),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta"))
    log:
        "logs/gatk/GenomicsDBImport/{chr}.info.log"
    benchmark:
        "benchmarks/gatk/GenomicsDBImport/{chr}.txt"
    run:
        gvcfs = _multi_flag(["-V", input.gvcfs])
        shell(
        "gatk GenomicsDBImport --java-options {params.custom} "
        "{gvcfs} "
        "--genomicsdb-workspace-path cohort "
        "-L {wildcards.chr} "
        ">& {log} ")

rule gatk_GenotypeGVCFs:
    input:
        expand("variant_calling/{chr}",
        chr=list(range(1, 1+config.get('rules').get(
                   'gatk_GenotypeGVCFs').get('range')))+config.get(
                   'rules').get('gatk_GenotypeGVCFs').get('extra'))
    output:
        "variant_calling/all.vcf"
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=4),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta"))
    log:
        "logs/gatk/GenotypeGVCFs/all.info.log"
    benchmark:
        "benchmarks/gatk/GenotypeGVCFs/all.txt"
    shell:
        "gatk GenotypeGVCFs --java-options {params.custom} "
        "-R {params.genome} "
        "-V gendb://cohort "
        "-O {output} "
        ">& {log} "