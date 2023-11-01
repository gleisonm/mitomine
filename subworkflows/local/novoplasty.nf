// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { CREATE_FILE                 } from '../../modules/local/createfile.nf'
include { POLISH_FILE                 } from '../../modules/local/polishfile.nf'
include { NOVOPLASTY as NOVOPLASTY_RUN              } from '../../modules/local/novoplasty.nf'
include { POLISH                      } from '../../modules/local/novoplastypolish.nf'
include { NOVOPLASTYSET               } from '../../modules/local/novoplastyset.nf'

workflow NOVOPLASTY {

    take:
    ch_reads

    main:

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
    //ch_versions = ch_versions.mix(NOVOPLASTY.out.versions)
    // if (!NOVOPLASTY_RUN.out.fasta) { 
    //     ch_polish = NOVOPLASTY_RUN.out.contigsfa
    // } else {
    //     ch_polish = NOVOPLASTY_RUN.out.fasta
    // }


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
   // ch_versions = ch_versions.mix(NOVOPLASTY.out.versions)

}

