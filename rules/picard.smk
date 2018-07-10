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
    return samples.loc[wildcards.sample, [optical_dup]].dropna()[0]



rule picard_MarkDuplicates:
   input:
       "reads/merged/{sample}.bam"
   output:
       bam=temp("reads/dedup/{sample}.dedup.bam"),
       bai="reads/dedup/{sample}.dedup.bai",
       metrics="reads/dedup/{sample}.metrics.txt"
   conda:
       "../envs/picard.yaml"
   params:
        custom=java_params(tmp_dir=tmp_path(path=config.get("paths").get("to_tmp")), fraction_for=4),
        #odpd = lambda wildcards: config.get("odpd").get(wildcards.sample,# 2500),
        odpd = lambda wildcards: get_odp(wildcards, samples, 'odp')
   benchmark:
       "benchmarks/picard/MarkDuplicates/{sample}.txt"
   log:
        "logs/picard/MarkDuplicates/{sample}.log"
   shell:
       "picard {params.custom} MarkDuplicates I={input} O={output.bam} "
       "M={output.metrics} REMOVE_DUPLICATES=false ASSUME_SORTED=true "
       "OPTICAL_DUPLICATE_PIXEL_DISTANCE={params.odpd} "
       "CREATE_INDEX=true"