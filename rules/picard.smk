# rule mark_duplicates:
#     input:
#         "reads/merged_samples/{sample}.bam"
#     output:
#         bam="reads/dedup/{sample}.bam",
#         metrics="reads/dedup/{sample}.metrics.txt"
#     log:
#         "logs/picard/dedup/{sample}.log"
#     params:
#         "REMOVE_DUPLICATES=true"
#     wrapper:
#         "0.27.0/bio/picard/markduplicates"
def get_odp(wildcards,samples,optical_dup='odp'):
    return "OPTICAL_DUPLICATE_PIXEL_DISTANCE={}".format(samples.loc[wildcards.sample, [optical_dup]].dropna()[0])

rule mark_duplicates:
    input:
        "reads/merged/{sample}.bam"
    output:
        bam=temp("reads/dedup/{sample}.dedup.bam"),
        metrics="reads/dedup/{sample}.metrics.txt"
    log:
        "logs/picard/MarkDuplicates/{sample}.log"
    benchmark:
        "benchmarks/picard/MarkDuplicates/{sample}.txt"
    params:
        java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=4),
        config.get("rules").get("picard_MarkDuplicates").get("arguments"),
        lambda wildcards: get_odp(wildcards, samples, 'odp')
    wrapper:
        "0.27.0/bio/picard/markduplicates"


#
# def get_odp(wildcards,samples,optical_dup='odp'):
#     return samples.loc[wildcards.sample, [optical_dup]].dropna()[0]
#
# rule picard_MarkDuplicates:
#    input:
#        "reads/merged/{sample}.bam"
#    output:
#        bam=temp("reads/dedup/{sample}.dedup.bam"),
#        bai="reads/dedup/{sample}.dedup.bai",
#        metrics="reads/dedup/{sample}.metrics.txt"
#    conda:
#        "../envs/picard.yaml"
#    params:
#         custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=4),
#         arguments=config.get("rules").get("picard_MarkDuplicates").get("arguments"),
#         odpd = lambda wildcards: get_odp(wildcards, samples, 'odp')
#    benchmark:
#        "benchmarks/picard/MarkDuplicates/{sample}.txt"
#    log:
#         "logs/picard/MarkDuplicates/{sample}.log"
#    shell:
#        "picard {params.custom} MarkDuplicates "
#        "I={input} O={output.bam} "
#        "M={output.metrics} {params.arguments} "
#        "OPTICAL_DUPLICATE_PIXEL_DISTANCE={params.odpd} &> {log}"


rule picard_InsertSizeMetrics:
   input:
       bam="reads/recalibrated/{sample}.dedup.recal.bam"
   output:
       metrics="reads/recalibrated/{sample}.dedup.recal.ismetrics.txt",
       histogram="reads/recalibrated/{sample}.dedup.recal.ismetrics.pdf"
   conda:
       "../envs/picard.yaml"
   params:
        custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=20),
   benchmark:
       "benchmarks/picard/IsMetrics/{sample}.txt"
   log:
       "logs/picard/IsMetrics/{sample}.log"
   shell:
       "picard {params.custom} CollectInsertSizeMetrics "
       "I={input.bam} "
       "O={output.metrics} "
       "H={output.histogram} "
       "&> {log} "

rule picard_WGSMetrics:
   input:
       bam="reads/recalibrated/{sample}.dedup.recal.bam"
   output:
       metrics="reads/recalibrated/{sample}.dedup.recal.wgsmetrics.txt"
   conda:
       "../envs/picard.yaml"
   params:
        custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=20),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta")),
        arguments=config.get("rules").get("picard_WGSMetrics").get("arguments")
   benchmark:
       "benchmarks/picard/WGSMetrics/{sample}.txt"
   log:
       "logs/picard/WGSMetrics/{sample}.log"
   shell:
       "picard {params.custom} CollectWgsMetrics "
       "{params.arguments} "
       "I={input.bam} "
       "O={output.metrics} "
       "R={params.genome} "
       "&> {log} "
