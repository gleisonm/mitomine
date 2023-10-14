process NOVOPLASTYSET {
    label 'process_single'

    output:
    
    path "*.pl", emit: run
   
   // path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    curl https://raw.githubusercontent.com/ndierckx/NOVOPlasty/master/NOVOPlasty4.3.4.pl > NOVOPlasty4.3.4.pl
    """

}
