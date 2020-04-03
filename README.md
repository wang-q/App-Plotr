[![Build Status](https://travis-ci.org/wang-q/App-Plotr.svg?branch=master)](https://travis-ci.org/wang-q/App-Plotr) [![Coverage Status](http://codecov.io/github/wang-q/App-Plotr/coverage.svg?branch=master)](https://codecov.io/github/wang-q/App-Plotr?branch=master) [![MetaCPAN Release](https://badge.fury.io/pl/App-Plotr.svg)](https://metacpan.org/release/App-Plotr)
# NAME

App::Plotr - Miscellaneous plots via R

# SYNOPSIS

    plotr <command> [-?h] [long options...]
            -? -h --help  show help

    Available commands:

      commands: list the application's commands
          help: display a command's help screen

         lines: scatter lines
          tree: draw newick trees
          venn: Venn diagram
          xlsx: convert xlsx to tsv

Run `plotr help command-name` for usage information.

# DESCRIPTION

App::Plotr draws miscellaneous plots via R

# INSTALLATION

    # Install Perl and R

    # R modules
    parallel -j 1 -k --line-buffer '
        Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { install.packages("{}", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") } '\''
        ' ::: \
            extrafont VennDiagram ggplot2 scales gridExtra \
            readr ape survival pROC

    # System fonts for R
    Rscript -e 'library(extrafont); font_import(prompt = FALSE); fonts();'

    # On errors of missing font
    # rm -fr /usr/local/lib/R/3.6/site-library/extrafont/
    # rm -fr /usr/local/lib/R/3.6/site-library/extrafontdb/

    cpanm --installdeps https://github.com/wang-q/App-Plotr/archive/0.0.1.tar.gz
    curl -fsSL https://raw.githubusercontent.com/wang-q/App-Plotr/master/share/check_dep.sh | bash

    cpanm -nq https://github.com/wang-q/App-Plotr.git

# AUTHOR

Qiang Wang <wang-q@outlook.com>

# LICENSE

This software is copyright (c) 2020 by Qiang Wang.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
