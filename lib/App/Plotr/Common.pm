package App::Plotr::Common;
use strict;
use warnings;
use autodie;

use 5.018001;

use Carp qw();
use IO::Zlib;
use IPC::Cmd qw();
use List::Util qw();
use List::MoreUtils qw();
use Path::Tiny qw();
use Statistics::R;
use Template;
use Tie::IxHash;
use YAML::Syck qw();

use Excel::Writer::XLSX;
use Spreadsheet::XLSX;
use Spreadsheet::ParseExcel;
use Text::CSV_XS qw();

use AlignDB::IntSpan;

sub read_lines {
    my $infile = shift;

    my $in_fh;
    if ( lc $infile eq "stdin" ) {
        $in_fh = *STDIN{IO};
    }
    else {
        $in_fh = IO::Zlib->new( $infile, "rb" );
    }

    my @lines;
    while ( my $line = $in_fh->getline ) {
        chomp $line;
        push @lines, $line;
    }
    close $in_fh;

    return @lines;
}

sub read_first_column {
    my $fn = shift;

    my @fields;

    my @lines = read_lines($fn);
    for (@lines) {
        my ($first) = split /\t/;
        push @fields, $first;
    }

    return @fields;
}

sub read_column {
    my $fn     = shift;
    my $second = shift // 2;

    tie my %result_of, "Tie::IxHash";

    my @lines = read_lines($fn);
    for (@lines) {
        /^#/ and next;
        my @fields = split /\t/;
        $result_of{ $fields[0] } = $fields[ $second - 1 ];
    }

    return \%result_of;
}

sub read_results {
    my $fn     = shift;

    tie my %result_of, "Tie::IxHash";

    my @lines = read_lines($fn);
    for (@lines) {
        /^#/ and next;
        my @fields = split /\t/;
        my $id = shift @fields;
        $result_of{$id} = [@fields];
    }

    return \%result_of;
}

sub exec_cmd {
    my $cmd = shift;
    my $opt = shift;

    if ( defined $opt and ref $opt eq "HASH" and $opt->{verbose} ) {
        print STDERR "CMD: ", $cmd, "\n";
    }

    system $cmd;
}

1;
