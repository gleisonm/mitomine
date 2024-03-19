process ISCIRC {
    fair true
    tag "$meta.id"
    label 'process_single'

    //container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/alpine:b31dd6ba7d28':
    //    'alpine:b31dd6ba7d28' }"

    input:
    tuple val(meta), path(mitochondrion)

    output:
    tuple val(meta), path('Circularized*.fa*'), optional: true     , emit: fasta_for_annotation

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    sed -i '1s/\$/ topology=circular/' ${mitochondrion}
    """

    stub:
    def args = task.ext.args ?: ''

    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
