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

    # System fonts for R
    Rscript -e 'if (!requireNamespace("extrafont", quietly = TRUE)) { install.packages("extrafont", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") }'
    Rscript -e 'library(extrafont); font_import(prompt = FALSE); fonts();'
    
    # R modules
    Rscript -e 'if (!requireNamespace("ggplot2", quietly = TRUE)) { install.packages("ggplot2", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") }'
    Rscript -e 'if (!requireNamespace("VennDiagram", quietly = TRUE)) { install.packages("VennDiagram", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") }'
    Rscript -e 'if (!requireNamespace("ape", quietly = TRUE)) { install.packages("ape", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") }'

    cpanm --installdeps https://github.com/wang-q/App-Plotr/archive/0.0.1.tar.gz
    curl -fsSL https://raw.githubusercontent.com/wang-q/App-Plotr/master/share/check_dep.sh | bash

    cpanm -nq https://github.com/wang-q/App-Plotr.git

# AUTHOR

Qiang Wang <wang-q@outlook.com>

# LICENSE

This software is copyright (c) 2020 by Qiang Wang.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
