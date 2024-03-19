
process NOVOPLASTY_RENAME {
    fair true
    tag "$meta.id"
    label 'process_single'

    input:
    tuple val(meta), path(fastq1)
    tuple val(meta), path(fastq2)
    tuple val(meta), path(mtdna_novoplasty)

    output:

    tuple val(meta), path('C*.fasta',includeInputs:true)            , emit: contigs
    tuple val(meta), path('*_1.fa*', includeInputs:true)            , emit: fastq1
    tuple val(meta), path('*_2.fa*', includeInputs:true)            , emit: fastq2

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    sed -i '1s/>.*/>'"${prefix}"'/' ${mtdna_novoplasty}
    """

}
