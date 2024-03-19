// positional arguments:
//   {filter,assemble,findmitoscaf,annotate,visualize,all}
//     filter              Filter input fastq reads.
//     assemble            Mitochondrial genome assembly from input fastq files.
//     findmitoscaf        Search for mitochondrial sequences from input fasta file.
//     annotate            Annotate PCGs, tRNA and rRNA genes.
//     visualize           Visualize input GenBank file.
//     all                 Run all steps for mitochondrial genome anlysis from input fastq files.


process MITOZ {
    fair true
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::mitoz=3.6"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'quay.io/biocontainers/mitoz:3.6--pyhdfd78af_0':
        'biocontainers/mitoz:3.6--pyhdfd78af_1' }"

    input:
    tuple val(meta), path(reads)
    val(clade)
    val(code)
    val(taxa)
    val(activity)

    output:

    tuple val(meta), path('*.result', includeInputs:true), optional: true            , emit: assemble
    tuple val(meta), path('*.result/*megahit.result/*.mitogenome.fa')                , emit: mitogenome

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def mem = (task.memory =~ /\b(\d+)\b/)[0][1]


    """
mitoz $activity \\
--outprefix $prefix \\
--thread_number $task.cpus \\
--clade Chordata \\
--genetic_code 2 \\
--fq1 ${reads[0]} \\
--fq2 ${reads[1]} \\
--fastq_read_length 151 \\
--assembler megahit \\
--kmers_megahit 43 71 99 119 141 \\
--memory $mem \\
--requiring_taxa Chordata \\
$args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(mitoz --version 2>&1) | sed 's/^.*mitoz //; s/Using.*\$//' ))
    END_VERSIONS
    """

}
