rule multiqc:
    input:
        expand("qc/untrimmed_{unit.unit}.html",
               unit=units.reset_index().itertuples()),
        expand("qc/trimmed_{unit.unit}.html",
               unit=units.reset_index().itertuples()),
        expand("reads/trimmed/{unit.unit}-R1.fq.gz_trimming_report.txt",
               unit=units.reset_index().itertuples()),
        expand("reads/dedup/{sample.sample}.metrics.txt",
              sample=samples.reset_index().itertuples()),
        expand("logs/gatk/BaseRecalibratorSpark/{sample.sample}_BQSR_data_processing_info.log",
              sample=samples.reset_index().itertuples()),
        expand("logs/gatk/ApplyBQSRSpark/{sample.sample}.post_recalibrate_info.log",
              sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.dedup.recal.ismetrics.txt",
              sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.dedup.recal.wgsmetrics.txt",
              sample=samples.reset_index().itertuples())

    output:
        "qc/multiqc.html"
    params:
        config.get("rules").get("multiqc").get("arguments")
    log:
        "logs/multiqc/multiqc.log"
    wrapper:
        "0.27.0/bio/multiqc"


# rule start_multiqc:
#     input:
#         expand("reads/merged/{sample.sample}.cram",
#               sample=samples.reset_index().itertuples()),
#         expand("reads/trimmed/{unit}-R1.fq.gz_trimming_report.txt",
#                unit=units.reset_index().itertuples())
#     output:
#         "logs/.multiqc"
#     shell:
#         "touch {output}"


rule fastqc:
    input:
       "reads/{unit}-R1.fq.gz",
       "reads/{unit}-R2.fq.gz"
    output:
        html="qc/untrimmed_{unit}.html",
        zip="qc/untrimmed_{unit}_fastqc.zip"
    params: ""
    wrapper:
        "0.27.0/bio/fastqc"

rule fastqc_trimmed:
    input:
       "reads/trimmed/{unit}-R1-trimmed.fq.gz",
       "reads/trimmed/{unit}-R2-trimmed.fq.gz"
    output:
        html="qc/trimmed_{unit}.html",
        zip="qc/trimmed_{unit}_fastqc.zip"
    params: ""
    wrapper:
        "0.27.0/bio/fastqc"
