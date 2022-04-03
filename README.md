[![Build Status](https://travis-ci.org/wang-q/App-Plotr.svg?branch=master)](https://travis-ci.org/wang-q/App-Plotr) [![Coverage Status](http://codecov.io/github/wang-q/App-Plotr/coverage.svg?branch=master)](https://codecov.io/github/wang-q/App-Plotr?branch=master) [![MetaCPAN Release](https://badge.fury.io/pl/App-Plotr.svg)](https://metacpan.org/release/App-Plotr)
# NAME

App::Plotr - Miscellaneous plots via R

# SYNOPSIS

    plotr <command> [-?h] [long options...]
            --help (or -h)  show help
                            aka -?

    Available commands:

      commands: list the application's commands
          help: display a command's help screen

          hist: histogram
         lines: scatter lines
          tree: draw newick trees
           tsv: convert tsv to xlsx
          venn: Venn diagram
          xlsx: convert xlsx to tsv

Run `plotr help command-name` for usage information.

# DESCRIPTION

App::Plotr draws miscellaneous plots via R

# INSTALLATION

    # Install Perl and R

    # R packages
    parallel -j 1 -k --line-buffer '
        Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { install.packages("{}", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") } '\''
        ' ::: \
            extrafont remotes \
            VennDiagram ggplot2 scales gridExtra \
            readr ape

    # The Arial font under Ubuntu
    sudo apt install ttf-mscorefonts-installer
    sudo fc-cache -fv

    # System fonts for R
    Rscript -e 'library(remotes); options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN")); remotes::install_version("Rttf2pt1", version = "1.3.8")'
    Rscript -e 'library(extrafont); font_import(prompt = FALSE); fonts();'

    # This module
    cpanm --installdeps https://github.com/wang-q/App-Plotr/archive/0.0.1.tar.gz
    curl -fsSL https://raw.githubusercontent.com/wang-q/App-Plotr/master/share/check_dep.sh | bash

    cpanm -nq https://github.com/wang-q/App-Plotr.git

# EXAMPLES

## Example \`plotr venn\`

    plotr venn t/rocauc.result.tsv t/mcox.05.result.tsv t/mcox.result.tsv --device png -o example/venn.png

<div>
    <p><img src="https://raw.githubusercontent.com/wang-q/App-Plotr/master/example/venn.png" alt="Output from `plotr venn`" /></p>
</div>

## Example \`plotr tree\`

    plotr tree t/YDL184C.nwk --device png -o example/tree.png

<div>
    <p><img src="https://raw.githubusercontent.com/wang-q/App-Plotr/master/example/tree.png" alt="Output from `plotr tree`" /></p>
</div>

## Example \`plotr lines\`

    plotr lines t/d1.tsv \
        --font Helvetica \
        --xl "Distance to indels ({italic(d)[1]})" \
        --yl "Nucleotide divergence ({italic(D)})" \
        --device png -o example/lines.png

<div>
    <p><img src="https://raw.githubusercontent.com/wang-q/App-Plotr/master/example/lines.png" alt="Output from `plotr lines`" /></p>
</div>

## Example \`plotr hist\`

    plotr hist t/hist.tsv \
        -g 2 \
        --width 2 \
        --xl "Weight ({bold(M/F)})" \
        --ymm 0,45 \
        --device png -o example/hist.png

<div>
    <p><img src="https://raw.githubusercontent.com/wang-q/App-Plotr/master/example/hist.png" alt="Output from `plotr hist`" /></p>
</div>

## Example \`plotr tsv\`

    plotr tsv t/rocauc.result.tsv \
        --header \
        --le 4:0.5 --ge 4:0.6 --bt 4:0.52:0.58 --contain 1:m03 \
        -o example/tsv.xlsx

<div>
    <p><img src="https://raw.githubusercontent.com/wang-q/App-Plotr/master/example/tsv.png" alt="Output from `plotr tsv`" /></p>
</div>

# AUTHOR

Qiang Wang <wang-q@outlook.com>

# LICENSE

This software is copyright (c) 2020 by Qiang Wang.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
