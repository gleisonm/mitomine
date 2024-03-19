process HETEROPLASMY_FILE {
    fair true
    tag "$meta"
    label 'process_single'

    input:
    tuple val(meta), path(fastq1)   //fastq_1
    tuple val(meta), path(fastq2)   //fastq_2
    tuple val(meta), path(mtdna)

    output:
    path("config.txt")                                                , emit: config //Config file to run NOVOPlasty
    tuple val(meta), path('*.fa', includeInputs:true)             , emit: fasta
    tuple val(meta), path('*_1.fastq*', includeInputs:true)              , emit: fastq1
    tuple val(meta), path('*_2.fastq*', includeInputs:true)              , emit: fastq2

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"

    """
echo "
Project:
-----------------------
Project name          = ${prefix}
Type                  = mito
Genome Range          = 13000-18000
K-mer                 = 33
Max memory            = 120
Extended log          = 0
Save assembled reads  = no
Seed Input            = $mtdna
Extend seed directly  = no
Reference sequence    = $mtdna
Variance detection    =
Chloroplast sequence  =

Dataset 1:
-----------------------
Read Length           = 151
Insert size           = 525
Platform              = illumina
Single/Paired         = PE
Combined reads        =
Forward reads         = $fastq1
Reverse reads         = $fastq2
Store Hash            =

Heteroplasmy:
-----------------------
MAF                   = 0.006
HP exclude list       =
PCR-free              = yes

Optional:
-----------------------
Insert size auto      = yes
Use Quality Scores    = no
Reduce ambigious N's  =
Output path           =
" > config.txt
    """
}
