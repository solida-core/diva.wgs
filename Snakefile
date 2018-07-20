import pandas as pd
from snakemake.utils import validate, min_version
##### set minimum snakemake version #####
min_version("5.1.2")

##### load config and sample sheets #####

configfile: "config.yaml"

samples = pd.read_table(config["samples"], index_col="sample")
units = pd.read_table(config["units"], index_col=["unit"], dtype=str)
#units.index = units.index.set_levels([i.astype(str) for i in units.index.levels]) # enforce str in index


##### local rules #####

localrules: all, pre_rename_fastq_pe, post_rename_fastq_pe


##### target rules #####

rule all:
    input:
        "qc/multiqc.html",
#        expand("reads/trimmed/{unit.unit}-R{read}-trimmed.fq.gz",
#               unit=units.reset_index().itertuples(),
#               read=[1, 2]),
#        expand("reads/aligned/{unit.unit}_fixmate.cram",
#               unit=units.reset_index().itertuples()),
#        expand("reads/sorted/{unit.unit}_sorted.cram",
#               unit=units.reset_index().itertuples()),
#        expand("reads/merged/{sample.sample}.cram",
#               sample=samples.reset_index().itertuples()),
#        expand("reads/dedup/{sample.sample}.dedup.bam",
#            sample=samples.reset_index().itertuples()),
#        expand("reads/recalibrated/{sample.sample}.dedup.recal.bam",
#               sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.recalibration_plots.pdf",
               sample=samples.reset_index().itertuples()),
#        expand("reads/recalibrated/{sample.sample}.dedup.recal.ismetrics.pdf",
#               sample=samples.reset_index().itertuples()),
#        expand("reads/recalibrated/{sample.sample}.dedup.recal.wgsmetrics.txt",
#              sample=samples.reset_index().itertuples()),
#        expand("variant_calling/{sample.sample}.{chr}.g.vcf",
#               sample=samples.reset_index().itertuples(),
#               chr=list(range(1, 1+config.get('rules').get(
#                   'gatk_GenotypeGVCFs').get('range')))+config.get(
#                   'rules').get('gatk_GenotypeGVCFs').get('extra')),
#        expand("variant_calling/{sample}.{chr}",
#               sample="ERS1004436",
#               chr=list(range(1, 1+config.get('rules').get(
#                   'gatk_GenotypeGVCFs').get('range')))+config.get(
#                   'rules').get('gatk_GenotypeGVCFs').get('extra')),
#        expand("variant_calling/{sample}.{chr}",
#               sample="ERS1004437",
#               chr=list(range(1, 1+config.get('rules').get(
#                   'gatk_GenotypeGVCFs').get('range')))+config.get(
#                   'rules').get('gatk_GenotypeGVCFs').get('extra'))
         expand("variant_calling/all.{chr}.vcf",
                    chr=list(range(1, 1+config.get('rules').get(
                   'gatk_GenotypeGVCFs').get('range')))+config.get(
                   'rules').get('gatk_GenotypeGVCFs').get('extra')),
         "variant_calling/all.snp_recalibrated.indel_recalibrated.vcf"


##### setup singularity #####

# this container defines the underlying OS for each job when using the workflow
# with --use-conda --use-singularity
singularity: "docker://continuumio/miniconda3:4.4.10"


##### load rules #####

include_prefix="rules"

include:
    include_prefix + "/functions.py"
include:
    include_prefix + "/trimming.smk"
include:
    include_prefix + "/alignment.smk"
include:
    include_prefix + "/samtools.smk"
include:
    include_prefix + "/picard.smk"
include:
    include_prefix + "/bqsr.smk"
include:
    include_prefix + "/call_variants.smk"
include:
    include_prefix + "/joint_call.smk"
include:
    include_prefix + "/vqsr.smk"
include:
    include_prefix + "/qc.smk"
