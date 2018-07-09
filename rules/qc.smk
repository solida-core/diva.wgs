rule multiqc:
    input:
        "logs/.multiqc"
    output:
        "qc/multiqc.html"
    params:
        config.get("rules").get("multiqc").get("arguments")
    log:
        "logs/multiqc/multiqc.log"
    wrapper:
        "0.27.0/bio/multiqc"


rule start_multiqc:
    input:
        expand("reads/merged_samples/{sample.sample}.cram",
              sample=samples.reset_index().itertuples())
    output:
        "logs/.multiqc"
    shell:
        "touch {output}"