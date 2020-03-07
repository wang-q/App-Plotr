# NAME

App::Plotr - Miscellaneous plots via R

# SYNOPSIS

    plotr <command> [-?h] [long options...]
        -? -h --help  show help

    Available commands:

    commands: list the application's commands
        help: display a command's help screen

        venn: Venn diagram

Run `plotr help command-name` for usage information.

# DESCRIPTION

App::Plotr draws miscellaneous plots via R

# INSTALLATION

    # System fonts for R
    Rscript -e 'if (!requireNamespace("extrafont", quietly = TRUE)) { install.packages("extrafont", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") }'
    Rscript -e 'library(extrafont); font_import(prompt = FALSE); fonts();'
    
    # R modules
    Rscript -e 'if (!requireNamespace("ggplot2", quietly = TRUE)) { install.packages("ggplot2", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") }'
    Rscript -e 'if (!requireNamespace("VennDiagram", quietly = TRUE)) { install.packages("VennDiagram", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") }'

    cpanm --installdeps App-Plotr-*.tar.gz
    # bash share/check_dep.sh
    cpanm -nq App-Plotr-*.tar.gz

# AUTHOR

Qiang Wang <wang-q@outlook.com>

# LICENSE

This software is copyright (c) 2020 by Qiang Wang.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
