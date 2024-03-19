//Modules to ASSEMBLY subworkflow
include { CREATE_FILE                  } from '../../modules/local/createfile.nf'
include { POLISH_FILE                  } from '../../modules/local/polishfile.nf'
include { NOVOPLASTY as NOVOPLASTY_RUN } from '../../modules/local/novoplasty.nf'
include { POLISH                       } from '../../modules/local/novoplastypolish.nf'
include { NOVOPLASTYSET                } from '../../modules/local/novoplastyset.nf'
include { MITOZ                        } from '../../modules/local/mitoz.nf'
include { ISCIRC                       } from '../../modules/local/iscirc.nf'
include { NOVOPLASTY_RENAME            } from '../../modules/local/novoplasty_rename.nf'
include { HETEROPLASMY_FILE            } from '../../modules/local/heteroplasmyfile.nf'
include { HETEROPLASMY_RUN             } from '../../modules/local/heteroplasmyrun.nf'

workflow ASSEMBLY {

    take:
    ch_reads // channel: [ val(meta), [ fasta ] ]

    main:

    //ch_novoplasty = Channel.empty()
    //ch_mitoz = Channel.empty()

    //
    // NOVOPlasty
    //

    if (params.skip_assembly) {

    ch_assembled_files = Channel
                            .fromPath(params.assembled_files)
                            .splitCsv(header: true, sep: ',')

    ch_fastq1 = ch_assembled_files
                                .map { row -> tuple(row.sample, file(row.fastq1)) }
    ch_fastq2 = ch_assembled_files
                                .map { row -> tuple(row.sample, file(row.fastq2)) }
    ch_mtdna = ch_assembled_files
                                .map { row -> tuple(row.sample, file(row.mtdna)) }

    HETEROPLASMY_FILE (
        ch_fastq1,
        ch_fastq2,
        ch_mtdna
    )

    HETEROPLASMY_RUN (
        HETEROPLASMY_FILE.out.fastq1,
        HETEROPLASMY_FILE.out.fastq2,
        HETEROPLASMY_FILE.out.config,
        HETEROPLASMY_FILE.out.fasta,
        params.np_pl
    )

    } else {

    CREATE_FILE (
        ch_reads,
        params.seed,
        'first'
    )

    NOVOPLASTY_RUN (
        CREATE_FILE.out.config,
        CREATE_FILE.out.fastq1,
        CREATE_FILE.out.fastq2,
        params.seed,
        params.np_pl
    )

    POLISH_FILE (
        NOVOPLASTY_RUN.out.fastq1,
        NOVOPLASTY_RUN.out.fastq2,
        NOVOPLASTY_RUN.out.contigs
    )

    POLISH (
        POLISH_FILE.out.fastq1,
        POLISH_FILE.out.fastq2,
        POLISH_FILE.out.config,
        POLISH_FILE.out.contigs,
        params.np_pl
    )

        NOVOPLASTY_RENAME (
        POLISH_FILE.out.fastq1,
        POLISH_FILE.out.fastq2,
        POLISH_FILE.out.contigs
    )

    // HETEROPLASMY

    HETEROPLASMY_FILE (
        POLISH.out.fastq1,
        POLISH.out.fastq2,
        POLISH.out.fasta
    )

    HETEROPLASMY_RUN (
        HETEROPLASMY_FILE.out.fastq1,
        HETEROPLASMY_FILE.out.fastq2,
        HETEROPLASMY_FILE.out.config,
        HETEROPLASMY_FILE.out.fasta,
        params.np_pl
    )
        }
    if (POLISH.out.fasta) {

        ISCIRC (
    POLISH.out.fasta
        )


    //ch_novoplasty = ch_novoplasty.mix(ISCIRC.out.fasta_for_annotation)


    //MitoZ


    //MITOZ (
    //    ch_reads,
    //    'Chordata', //params
    //    '2',        //params
    //    'Chordata', //params
    //    'all'  //params
    //)

    //ch_mitoz = ch_mitoz.mix(MITOZ.out.mitogenome)


    //ch_mitoz.dump(tag: 'mitoz')
    //ch_novoplasty.dump(tag: 'novoplasty')

    //
    // GetOrganelle
    //

    //
    //Unicycler
    //

    //
    // Output
    //

    //MULTIFASTA (
    //    ch_novoplasty,
    //    ch_mitoz
    //)

    //emit:
    //mtdna_novoplasty = ch_novoplasty
    //mtdna_mitoz      = ch_mitoz
    }
}

