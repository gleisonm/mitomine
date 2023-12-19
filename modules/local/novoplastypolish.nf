process POLISH {
    tag "$meta.id"
    label 'process_high'

    conda "conda-forge/packages/perl"
   // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
   //     'https://depot.galaxyproject.org/singularity/novoplasty' :
   //     'biocontainers/novoplasty' }"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/perl' :
        'quay.io/biocontainers/perl:5.22.2.1' }"



    input:
    path(file)                      //Config file to run NOVOPlasty
    tuple val(meta), path(fastq1)   //fastq_1
    tuple val(meta), path(fastq2)   //fastq_2
    tuple val(meta), path(seed)     //fasta from already assembled mitochondrion
    path run

    output:
    tuple val(meta), path('Circularized*.fa*'), optional: true     , emit: fasta        //Circularized fasta
    tuple val(meta), path('contigs*.txt')                          , emit: contigs      //Contigs from incomplete circ
    tuple val(meta), path('Contigs*.fasta'), optional: true        , emit: contigsfa    //Contigs Fasta from incomplete circ
    tuple val(meta), path('log*.txt')                              , emit: log          //log


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


