process POLISH_FILE {
    fair true
    tag "$meta.id"
    label 'process_single'

    input:
    tuple val(meta), path(fastq1)
    tuple val(meta), path(fastq2)
    tuple val(meta), path(seed)


    output:
    path("config.txt")            , emit: config
    tuple val(meta), path('C*.fasta', includeInputs:true)             , emit: contigs
    tuple val(meta), path('*_1.fa*', includeInputs:true)              , emit: fastq1
    tuple val(meta), path('*_2.fa*', includeInputs:true)              , emit: fastq2

    when:
    task.ext.when == null || task.ext.when


    script:
    //def params = file(out.log.novoplasty).eachLine{ str -> printlc "line ${genomerange}: $str}
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
echo "
Project:
-----------------------
Project name          = ${prefix}_polish
Type                  = mito
Genome Range          = 13000-18000
K-mer                 = 33
Max memory            = 120
Extended log          = 0
Save assembled reads  = no
Seed Input            = $seed
Extend seed directly  = yes
Reference sequence    =
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
MAF                   =
HP exclude list       =
PCR-free              =

Optional:
-----------------------
Insert size auto      = yes
Use Quality Scores    = no
Reduce ambigious N's  = yes
Output path           =
" > config.txt
    """
}
