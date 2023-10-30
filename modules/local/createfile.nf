process CREATE_FILE {
    tag "$meta.id"
    label 'process_single'

    input:
    tuple val(meta), path(reads)
    path(seed)
    val(run)

    output:
    path("config.txt")            , emit: config

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
Forward reads         = /data/home/gleison.azevedo/ciclideos/data/raw/${reads[0]}
Reverse reads         = /data/home/gleison.azevedo/ciclideos/data/raw/${reads[1]}
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
