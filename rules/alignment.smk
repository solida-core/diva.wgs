
rule bwa_mem:
    input: 
        "reads/trimmed/{sample}-{unit}-R1-trimmed.fq.gz",
        "reads/trimmed/{sample}-{unit}-R2-trimmed.fq.gz"
    output: 
        "reads/aligned/{sample}-{unit}_fixmate.cram"
    conda:
        "../envs/bwa_mem.yaml"
    params:
        sample="{unit.sample}",
        custom=config.get("rules").get("bwa-mem").get("arguments"),
        platform=config.get("rules").get("bwa-mem").get("platform"),
        platform_unit=lambda wildcards: '.'.join(wildcards.unit.split('.')[:-1]),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta")),
        output_fmt="CRAM"
    log:
        "logs/bwa_mem/{sample}-{unit}.log"
    benchmark:
        "benchmarks/bwa/mem/{sample}-{unit}.txt"
    threads: conservative_cpu_count()
    shell:
        'bwa mem {params.custom} '
        r'-R "@RG\tID:{wildcards.unit}\tSM:{params.sample}\tPL:{params.platform}\tLB:lib1\tPU:{params.platform_unit}" '
        '-t {threads} {params.genome} {input} 2> {log} '
        '|samtools fixmate --threads {threads} '
        '-O {params.output_fmt} '
        '--reference {params.genome} '
        '- {output} '

