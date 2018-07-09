# def get_fastq(wildcards, units):
#     return units.loc[(wildcards.unit['sample'], wildcards.unit.unit),
#                      ["fq1", "fq2"]].dropna()

def get_fastq(wildcards,units,read_pair='fq1'):
    return units.loc[(wildcards.sample, wildcards.unit),
                     [read_pair]].dropna()[0]


rule pre_rename_fastq_pe:
    input:
        r1=lambda wildcards: get_fastq(wildcards, units, 'fq1'),
        r2=lambda wildcards: get_fastq(wildcards, units, 'fq2')
    output:
        r1=temp("reads/{sample}-{unit}-R1.fq.gz"),
        r2=temp("reads/{sample}-{unit}-R2.fq.gz")
    shell:
        "ln -s {input.r1} {output.r1} &&"
        "ln -s {input.r2} {output.r2} "


rule trim_galore_pe:
    input:
        ["reads/{sample}-{unit}-R1.fq.gz", "reads/{sample}-{unit}-R2.fq.gz"]
    output:
        temp("reads/trimmed/{sample}-{unit}-R1_val_1.fq.gz"),
        "reads/trimmed/{sample}-{unit}-R1.fq.gz_trimming_report.txt",
        temp("reads/trimmed/{sample}-{unit}-R2_val_2.fq.gz"),
        "reads/trimmed/{sample}-{unit}-R2.fq.gz_trimming_report.txt"
    params:
        extra=config.get("rules").get("multiqc").get("arguments")
    log:
        "logs/trim_galore/{sample}-{unit}.log"
    wrapper:
        "0.27.0/bio/trim_galore/pe"


rule post_rename_fastq_pe:
    input:
        r1="reads/trimmed/{sample}-{unit}-R1_val_1.fq.gz",
        r2="reads/trimmed/{sample}-{unit}-R2_val_2.fq.gz"
    output:
        r1="reads/trimmed/{sample}-{unit}-R1-trimmed.fq.gz",
        r2="reads/trimmed/{sample}-{unit}-R2-trimmed.fq.gz"
    shell:
        "mv {input.r1} {output.r1} &&"
        "mv {input.r2} {output.r2} "
