process NOVOPLASTY {
    tag "$meta.id"
    label 'process_high'

    conda "conda-forge/packages/perl"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/perl' :
        'quay.io/biocontainers/perl:5.22.2.1' }"



    input:
    path(file)
    tuple val(meta), path(fastq1)
    tuple val(meta), path(fastq2)
    path(seed)
    path run

    output:

    //tuple val(meta), path('Circularized*.fa*'), optional: true        , emit: fasta
    tuple val(meta), path('contigs*.txt')                             , emit: tmp
    tuple val(meta), path('C*.fasta')                                 , emit: contigs
    tuple val(meta), path('log*.txt')                                 , emit: log
    tuple val(meta), path('*_1.fa*', includeInputs:true)            , emit: fastq1
    tuple val(meta), path('*_2.fa*', includeInputs:true)            , emit: fastq2



    //path "versions.yml"                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    perl $run -c $file

    """
}


//    cat <<-END_VERSIONS > versions.yml
//    "${task.process}":
//       : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
//    END_VERSIONS
//    """


