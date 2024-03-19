process HETEROPLASMY_RUN {
    fair true
    tag "$meta"
    label 'process_high'
    label 'error_bug'

    conda "conda-forge/packages/perl"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/perl' :
        'quay.io/biocontainers/perl:5.22.2.1' }"

    input:
    tuple val(meta), path(fastq1)   //fastq_1
    tuple val(meta), path(fastq2)   //fastq_2
    path(file)                      //Config file to run NOVOPlasty
    tuple val(meta), path(mtdna)    //fasta from already assembled mitochondrion
    path run

    output:

    tuple val(meta), path('Circos_links_*.txt')    , emit: circlinks
    tuple val(meta), path('Circos_mutations*.txt') , emit: circmuts
    tuple val(meta), path('*_assemblies_*.fasta')  , emit: heteroplasmy
    tuple val(meta), path('*.vcf')                 , emit: variants
    tuple val(meta), path('Linkage*.txt')          , emit: linkage
    tuple val(meta), path('log*.txt')              , emit: log

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    perl $run -c $file

    """
}

