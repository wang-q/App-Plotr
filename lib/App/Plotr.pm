package App::Plotr;

our $VERSION = "0.0.3";

use strict;
use warnings;
use App::Cmd::Setup -app;

=pod

=encoding utf-8

=head1 NAME

App::Plotr - Miscellaneous plots via R

=head1 SYNOPSIS

    plotr <command> [-?h] [long options...]
            --help (or -h)  show help
                            aka -?

    Available commands:

      commands: list the application's commands
          help: display a command's help screen

         lines: scatter lines
          tree: draw newick trees
           tsv: convert tsv to xlsx
          venn: Venn diagram
          xlsx: convert xlsx to tsv

Run C<plotr help command-name> for usage information.

=head1 DESCRIPTION

App::Plotr draws miscellaneous plots via R

=head1 INSTALLATION

    # Install Perl and R

    # R modules
    parallel -j 1 -k --line-buffer '
        Rscript -e '\'' if (!requireNamespace("{}", quietly = TRUE)) { install.packages("{}", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN") } '\''
        ' ::: \
            extrafont remotes \
            VennDiagram ggplot2 scales gridExtra \
            readr ape survival pROC

    # The Arial font under Ubuntu
    sudo apt install ttf-mscorefonts-installer
    sudo fc-cache -f

    # System fonts for R
    Rscript -e 'library(remotes); options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN")); remotes::install_version("Rttf2pt1", version = "1.3.8")'
    Rscript -e 'library(extrafont); font_import(prompt = FALSE); fonts();'

    # On errors of missing font
    # rm -fr /usr/local/lib/R/3.6/site-library/extrafont/
    # rm -fr /usr/local/lib/R/3.6/site-library/extrafontdb/

    cpanm --installdeps https://github.com/wang-q/App-Plotr/archive/0.0.1.tar.gz
    curl -fsSL https://raw.githubusercontent.com/wang-q/App-Plotr/master/share/check_dep.sh | bash

    cpanm -nq https://github.com/wang-q/App-Plotr.git

=head1 AUTHOR

Qiang Wang E<lt>wang-q@outlook.comE<gt>

=head1 LICENSE

This software is copyright (c) 2020 by Qiang Wang.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__END__
