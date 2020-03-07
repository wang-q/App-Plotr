package App::Plotr;

our $VERSION = "0.0.1";

use strict;
use warnings;
use App::Cmd::Setup -app;

=pod

=encoding utf-8

=head1 NAME

App::Plotr - Miscellaneous plots via R

=head1 SYNOPSIS

    plotr <command> [-?h] [long options...]
        -? -h --help  show help

    Available commands:

    commands: list the application's commands
        help: display a command's help screen

        venn: Venn diagram

Run C<plotr help command-name> for usage information.

=head1 DESCRIPTION

App::Plotr draws miscellaneous plots via R

=head1 INSTALLATION

    # System fonts for R
    Rscript -e 'if (!requireNamespace("extrafont", quietly = TRUE)) { install.packages("extrafont", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") }'
    Rscript -e 'library(extrafont); font_import(prompt = FALSE); fonts();'
    
    # R modules
    Rscript -e 'if (!requireNamespace("ggplot2", quietly = TRUE)) { install.packages("ggplot2", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") }'
    Rscript -e 'if (!requireNamespace("VennDiagram", quietly = TRUE)) { install.packages("VennDiagram", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") }'

    cpanm --installdeps App-Plotr-*.tar.gz
    # bash share/check_dep.sh
    cpanm -nq App-Plotr-*.tar.gz

=head1 AUTHOR

Qiang Wang E<lt>wang-q@outlook.comE<gt>

=head1 LICENSE

This software is copyright (c) 2020 by Qiang Wang.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__END__
