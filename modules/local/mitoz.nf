// positional arguments:
//   {filter,assemble,findmitoscaf,annotate,visualize,all}
//     filter              Filter input fastq reads.
//     assemble            Mitochondrial genome assembly from input fastq files.
//     findmitoscaf        Search for mitochondrial sequences from input fasta file.
//     annotate            Annotate PCGs, tRNA and rRNA genes.
//     visualize           Visualize input GenBank file.
//     all                 Run all steps for mitochondrial genome anlysis from input fastq files.


process MITOZ {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::mitoz=3.6"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mitoz:3.6--pyhdfd78af_0':
        'biocontainers/mitoz:3.6--pyhdfd78af_1' }"

    input:
    tuple val(meta), path(bam)

    output:



    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
mitoz $activity \\
--outprefix $prefix \\
--thread_number $task.cpus \\
--clade Chordata \\
--genetic_code 2 \\
--species_name "$prefix" \\
--fq1 $fastq1 \\
--fq2 $fastq2 \\
--fastq_read_length 151 \\
--data_size_for_mt_assembly 3,0 \\
--assembler megahit \\
--kmers_megahit 59 79 99 119 141 \\
--memory $task.memory \\
--requiring_taxa Chordata \\
$args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(mitoz --version 2>&1) | sed 's/^.*mitoz //; s/Using.*\$//' ))
    END_VERSIONS
    """

}
