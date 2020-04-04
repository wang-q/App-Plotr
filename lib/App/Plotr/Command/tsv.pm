package App::Plotr::Command::tsv;
use strict;
use warnings;
use autodie;

use App::Plotr -command;
use App::Plotr::Common;

sub abstract {
    return 'convert tsv to xlsx';
}

sub opt_spec {
    return (
        [ "outfile|o=s", "Output filename", ],
        [ "sheet|s=s",   "one sheet name, default is the basename of infile", ],
        [ "header",      "head line", ],
        [ "font_name=s", "font name", { default => "Arial" }, ],
        [ "font_size=i", "font size", { default => 10 }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "plotr tsv [options] <infile>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= <<'MARKDOWN';

* <infile> is a tsv file
* infile == stdin means reading from STDIN
* --outfile can't be stdout

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
        next if lc $_ eq "stdin";
        if ( !Path::Tiny::path($_)->is_file ) {
            $self->usage_error("The input file [$_] doesn't exist.");
        }
    }

    if ( !exists $opt->{outfile} ) {
        $opt->{outfile} = Path::Tiny::path( $args->[0] )->absolute . ".xlsx";
    }

    if ( !exists $opt->{sheet} ) {
        $opt->{sheet} = Path::Tiny::path( $args->[0] )->basename( ".tsv", ".tsv.gz" );
    }
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    #@type IO::Handle
    my $in_fh;
    if ( lc $args->[0] eq "stdin" ) {
        $in_fh = *STDIN{IO};
    }
    else {
        $in_fh = IO::Zlib->new( $args->[0], "rb" );
    }

    my $tsv = Text::CSV_XS->new(
        {   sep_char    => "\t",
            quote_char  => undef,
            escape_char => undef,
        }
    );

    #@type Excel::Writer::XLSX
    my $workbook = Excel::Writer::XLSX->new( $opt->{outfile} );
    my $format;
    {
        my %font = (
            font => $opt->{font_name},
            size => $opt->{font_size},
        );
        my %header = (
            align    => 'center',
            bg_color => 42,
            bold     => 1,
            bottom   => 2,
        );
        $format = {
            HEADER => $workbook->add_format( %header, %font, ),
            NORMAL => $workbook->add_format( color => 'black', %font, ),
        };
    }

    # convert
    my $worksheet  = $workbook->add_worksheet( $opt->{sheet} );
    my $row_cursor = 0;

    if ( $opt->{header} ) {
        my $colref = $tsv->getline($in_fh);
        $worksheet->write_row( $row_cursor, 0, $colref, $format->{HEADER} );
        $worksheet->freeze_panes( 1, 0 );    # freeze header

        $row_cursor++;
    }

    while ( my $colref = $tsv->getline($in_fh) ) {
        $worksheet->write_row( $row_cursor, 0, $colref, $format->{NORMAL} );

        $row_cursor++;
    }

    $in_fh->close;
    $workbook->close;
}

1;
