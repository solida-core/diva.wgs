

rule gatk_GenomicsDBImport:
    input:
        gvcfs=expand("variant_calling/{sample.sample}.{{chr}}.g.vcf",
                     sample=samples.reset_index().itertuples())
    output:
        touch("variant_calling/dbimport/{chr}")
    wildcard_constraints:
        chr="[0-9XYM]+"
    params:
        custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=4),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta"))
    log:
        "logs/gatk/GenomicsDBImport/{chr}.info.log"
    benchmark:
        "benchmarks/gatk/GenomicsDBImport/{chr}.txt"
    run:
        gvcfs = _multi_flag("-V", input.gvcfs)
        shell(
        "gatk GenomicsDBImport --java-options {params.custom} "
        "{gvcfs} "
        "--genomicsdb-workspace-path cohort/{chr} "
        "-L {wildcards.chr} "
        ">& {log} ")

rule gatk_GenotypeGVCFs:
    input:
        "variant_calling/dbimport/{chr}"
        # expand("variant_calling/{chr}",
        #        sample=samples.reset_index().itertuples(),
        #        chr=list(range(1, 1+config.get('rules').get(
        #            'gatk_GenotypeGVCFs').get('range')))+config.get(
        #            'rules').get('gatk_GenotypeGVCFs').get('extra'))
    output:
        "variant_calling/all.{chr}.vcf"
    wildcard_constraints:
        chr="[0-9XYM]+"
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=4),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta"))
    log:
        "logs/gatk/GenotypeGVCFs/all.{chr}.info.log"
    benchmark:
        "benchmarks/gatk/GenotypeGVCFs/all.{chr}.txt"
    shell:
        "gatk GenotypeGVCFs --java-options {params.custom} "
        "-R {params.genome} "
        "-V gendb://cohort/{wildcards.chr} "
        "-O {output} "
        ">& {log} "