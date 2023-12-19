process CREATE_FILE {
    tag "$meta.id"
    label 'process_single'

    input:
    tuple val(meta), path(reads) //Fasta from samplesheet
    path(seed)                   //Already assembled mitochondrion
    val(run)                     //Number of NOVOPlasty runs

    output:
    path("config.txt")                                                , emit: config //Config file to run NOVOPlasty
    tuple val(meta), path('*_1.fast*', includeInputs:true)            , emit: fastq1 //fasta_1
    tuple val(meta), path('*_2.fast*', includeInputs:true)            , emit: fastq2 //fasta_2

    when:
    task.ext.when == null || task.ext.when


    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
echo "
Project:
-----------------------
Project name          = ${prefix}_${run}
Type                  = mito
Genome Range          = 13000-18000
K-mer                 = 33
Max memory            = 120
Extended log          = 0
Save assembled reads  = no
Seed Input            = $seed
Extend seed directly  = no
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
Forward reads         = ${reads[0]}
Reverse reads         = ${reads[1]}
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
Reduce ambigious N's  =
Output path           =
" > config.txt
    """
}
