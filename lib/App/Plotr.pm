package App::Plotr;

our $VERSION = "0.0.1";

use strict;
use warnings;
use App::Cmd::Setup -app;

=pod

=encoding utf-8

=head1 NAME

App::Plotr - miscellaneous plots via R

=head1 SYNOPSIS

    plotr <command> [-?h] [long options...]
            -? -h --help  show help

    Available commands:

       commands: list the application's commands
           help: display a command's help screen

            kmp: p-value of K-M for coxph predictions
           mcox: multivariate Cox regression
       nextstep: create jobs for next step of multivariate regression
           plot: plot Cox regression formula on different datasets
       plotvenn: plot Venn diagram
        predict: prediction scores of formulas
        replace: replace headers (markers) of a .tsv file
         rocauc: AUC of ROC for coxph predictions
         select: select some columns from a .tsv file
          split: split a .tsv file into chunks by columns or by rows
      transpose: swap rows and columns
           ucox: univariate Cox regression


Run C<plotr help command-name> for usage information.

=head1 DESCRIPTION

App::Plotr is a set of operations for Biomarker discovery.

=head1 INSTALLATION

    cpanm --installdeps App-Plotr-*.tar.gz
    # bash share/check_dep.sh
    cpanm -nq App-Plotr-*.tar.gz

=head1 SEE ALSO

=over 4

=item L<datamash|https://www.gnu.org/software/datamash/>

=item L<tsv-utils|https://ebay.github.io/tsv-utils/docs/ToolReference.html>

=item L<miller|http://johnkerl.org/miller/doc/10-min.html>

=item L<xsv|https://github.com/BurntSushi/xsv>

=item L<BDVal|http://campagnelab.org/software/bdval/>

=back

=head1 AUTHOR

Qiang Wang E<lt>wang-q@outlook.comE<gt>

=head1 LICENSE

This software is copyright (c) 2020 by Qiang Wang.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__END__
