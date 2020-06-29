
rule picard_InsertSizeMetrics:
   input:
       bam="reads/recalibrated/{sample}.dedup.recal.bam"
   output:
       metrics="reads/recalibrated/{sample}.dedup.recal.ismetrics.txt",
       histogram="reads/recalibrated/{sample}.dedup.recal.ismetrics.pdf"
   conda:
       "../envs/picard.yaml"
   params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=5),
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
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=5),
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
