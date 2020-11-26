rule multiqc:
    input:
        expand("reads/dedup/{sample.sample}.metrics.txt",
              sample=samples.reset_index().itertuples()),
        # expand("reads/recalibrated/{sample.sample}.recalibration_plots.pdf",
        #        sample=samples.reset_index().itertuples()),
        # expand("reads/recalibrated/{sample.sample}.dedup.recal.ismetrics.txt",
        #       sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.dedup.recal.wgsmetrics.txt",
              sample=samples.reset_index().itertuples())
    output:
        "qc/multiqc.html"
    params:
        params=config.get("rules").get("multiqc").get("arguments"),
        outdir="qc",
        outname="multiqc.html",
        fastqc="qc/fastqc/",
        trimming="reads/trimmed/",
        reheader=config.get("reheader")
    conda:
        "../envs/multiqc.yaml"
    log:
        "logs/multiqc/multiqc.log"
    shell:
        "multiqc "
        "{input} "
        "{params.fastqc} "
        "{params.trimming} "
        "{params.params} "
        "-o {params.outdir} "
        "-n {params.outname} "
        "--sample-names {params.reheader} "
        ">& {log}"