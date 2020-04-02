package App::Plotr::Command::xlsx;
use strict;
use warnings;
use autodie;

use App::Plotr -command;
use App::Plotr::Common;

sub abstract {
    return 'convert xlsx to tsv';
}

sub opt_spec {
    return (
        [ "outfile|o=s", "Output filename. [stdout] for screen.", ],
        [ "sheet|s=s",   "one sheet name, default is the first sheet", ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "plotr xlsx [options] <infile>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= <<'MARKDOWN';

* <infile> is a xlsx or xls file

MARKDOWN

    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( @{$args} != 1 ) {
        my $message = "This command need one input file.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
    for ( @{$args} ) {
        if ( !Path::Tiny::path($_)->is_file ) {
            $self->usage_error("The input file [$_] doesn't exist.");
        }
    }

    if ( !exists $opt->{outfile} ) {
        $opt->{outfile} = Path::Tiny::path( $args->[0] )->absolute . ".tsv";
    }

}

sub execute {
    my ( $self, $opt, $args ) = @_;

    my $excel;
    if ( $args->[0] =~ /\.xlsx$/ ) {
        $excel = Spreadsheet::XLSX->new($args->[0]);
    }
    else {
        $excel = Spreadsheet::ParseExcel->new->parse($args->[0]);
    }

    my $out_fh;
    if ( lc( $opt->{outfile} ) eq "stdout" ) {
        $out_fh = *STDOUT{IO};
    }
    else {
        open $out_fh, ">", $opt->{outfile};
    }

    my $tsv = Text::CSV_XS->new({
        sep_char => "\t",
        quote_char => undef,
        escape_char => undef,
    });


    my @sheets = $excel->worksheets;
    if ( !defined $opt->{sheet} ) {
        $opt->{sheet} = $sheets[0]->get_name;
    }

    for my $sheet (@sheets) {
        if ( $sheet->get_name eq $opt->{sheet} ) {
            $sheet->{MaxRow} ||= $sheet->{MinRow};

            for my $row ( $sheet->{MinRow} .. $sheet->{MaxRow} ) {
                $sheet->{MaxCol} ||= $sheet->{MinCol};
                my @fields;
                for my $col ( $sheet->{MinCol} .. $sheet->{MaxCol} ) {
                    my $cell = $sheet->{Cells}[$row][$col];
                    push @fields, $cell->{Val};
                }
                $tsv->say( $out_fh, \@fields );
            }
        }
    }

    close $out_fh;
}

1;
