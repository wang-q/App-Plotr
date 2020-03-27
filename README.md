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

    # Install Perl and R

    # R modules
    parallel -j 1 '
        Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { install.packages("{}", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") } '\''
    ' ::: extrafont VennDiagram ape ggplot2 scales gridExtra

    # System fonts for R
    Rscript -e 'library(extrafont); font_import(prompt = FALSE); fonts();'

    cpanm --installdeps https://github.com/wang-q/App-Plotr/archive/0.0.1.tar.gz
    curl -fsSL https://raw.githubusercontent.com/wang-q/App-Plotr/master/share/check_dep.sh | bash

    cpanm -nq https://github.com/wang-q/App-Plotr.git

# AUTHOR

Qiang Wang <wang-q@outlook.com>

# LICENSE

This software is copyright (c) 2020 by Qiang Wang.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
