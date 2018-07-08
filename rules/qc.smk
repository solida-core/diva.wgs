rule multiqc:
    input:
        expand("reads/trimmed/{unit.sample}-{unit.unit}-R1-trimmed.fq.gz",
               unit=units.reset_index().itertuples())
    output:
        "qc/multiqc.html"
    params:
        config.get("rules").get("multiqc").get("arguments")
    log:
        "logs/multiqc/multiqc.log"
    wrapper:
        "0.27.0/bio/multiqc"