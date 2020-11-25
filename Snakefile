import pandas as pd
from snakemake.utils import validate, min_version
##### set minimum snakemake version #####
min_version("5.10.0")

##### load config and sample sheets #####

#configfile: "config.yaml"

samples = pd.read_table(config["samples"], index_col="sample")
units = pd.read_table(config["units"], index_col=["unit"], dtype=str)
reheader = pd.read_csv(config["reheader"],index_col="Client", dtype=str, sep="\t")
reheader = reheader[reheader["LIMS"].isin(samples.index.values)]


##### local rules #####

localrules: all, pre_rename_fastq_pe, post_rename_fastq_pe, concatVcfs


##### target rules #####

rule all:
    input:
        "qc/multiqc.html",
        expand("reads/merged/{sample.sample}.cram.crai",
              sample=samples.reset_index().itertuples()),
        expand("variant_calling/all.{interval}.vcf.gz",
                interval=[str(i).zfill(4) for i in
                        range(0, int(config.get('rules').get
                        ('gatk_SplitIntervals').get('scatter-count')))]),
        "variant_calling/all.vcf.gz",
        "variant_calling/all.snp_recalibrated.indel_recalibrated.vcf.gz",
        # "delivery.completed"


##### load rules #####

include_prefix="rules"
dima_path="dima/"
include:
    include_prefix + "/functions.py"
include:
    dima_path + include_prefix + "/trimming.smk"
include:
    dima_path + include_prefix + "/alignment.smk"
include:
    dima_path + include_prefix + "/samtools.smk"
include:
    dima_path + include_prefix + "/picard.smk"
include:
    dima_path + include_prefix + "/bsqr.smk"
include:
       include_prefix + "/picard_stats.smk"
include:
    include_prefix + "/call_variants.smk"
include:
    include_prefix + "/joint_call.smk"
include:
    include_prefix + "/qc.smk"
include:
    include_prefix + "/vqsr.smk"
# include:
#     include_prefix + "/delivery.smk"
