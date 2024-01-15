//Modules to ASSEMBLY subworkflow
include { CREATE_FILE                  } from '../../modules/local/createfile.nf'
include { POLISH_FILE                  } from '../../modules/local/polishfile.nf'
include { NOVOPLASTY as NOVOPLASTY_RUN } from '../../modules/local/novoplasty.nf'
include { POLISH                       } from '../../modules/local/novoplastypolish.nf'
include { NOVOPLASTYSET                } from '../../modules/local/novoplastyset.nf'
include { MITOZ                        } from '../../modules/local/mitoz.nf'
include { ISCIRC                       } from '../../modules/local/iscirc.nf'

workflow ASSEMBLY {

    take:
    ch_reads // channel: [ val(meta), [ fasta ] ]

    main:

    //
    // NOVOPlasty
    //

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
        POLISH_FILE.out.config,
        NOVOPLASTY_RUN.out.fastq1,
        NOVOPLASTY_RUN.out.fastq2,
        NOVOPLASTY_RUN.out.contigs,
        params.np_pl
    )

    if (POLISH.out.fasta) {

        ISCIRC (
            POLISH.out.fasta
        )

    }
    // ch_versions = ch_versions.mix(NOVOPLASTY.out.versions)

    //
    // MitoZ
    //

    MITOZ (
        ch_reads,
        'Chordata', //params
        '2',        //params
        'Chordata', //params
        'assemble'     //params
    )

    //
    // GetOrganelle
    //

    //
    //Unicycler
    //
}

