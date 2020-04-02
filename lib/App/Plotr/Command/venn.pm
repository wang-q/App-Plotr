package App::Plotr::Command::venn;
use strict;
use warnings;
use autodie;

use App::Plotr -command;
use App::Plotr::Common;

sub abstract {
    return 'Venn diagram';
}

sub opt_spec {
    return (
        [ "outfile|o=s", "Output filename", ],
        [ "device=s", "png or pdf", { default => "pdf" }, ],
        [ "percent",   "format percent", ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "plotr venn [options] <infile> [more infiles]";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= <<'MARKDOWN';

* <infile> is a tab-separated file
    * First column contains identifiers, other columns are optional
    * VennDiagram supports up to 5 categories, means 5 infiles at most

* --outfile can't be stdout

MARKDOWN

    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( @{$args} < 1 ) {
        my $message = "This command need one to five input files.\n\tIt found";
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
        $opt->{outfile} = Path::Tiny::path( $args->[0] )->absolute . ".$opt->{device}";
    }

}

sub execute {
    my ( $self, $opt, $args ) = @_;

    my @fills  = qw{indianred1 deepskyblue palegreen burlywood purple};
    my @alphas = (0.5) x 5;

    my @cats = map { Path::Tiny::path($_)->basename(qr/\..+?/) } @{$args};
    my $count = scalar @cats;

    # first 5
    $count = 5 if ( $count > 5 );
    @cats   = splice @cats,   0, $count;
    @fills  = splice @fills,  0, $count;
    @alphas = splice @alphas, 0, $count;

    # avoid duplicated names
    {
        my %seen;
        for my $i ( 1 .. $count ) {
            if ( exists $seen{ $cats[ $i - 1 ] } ) {
                $cats[ $i - 1 ] = "cat$i";
            }
            else {
                $seen{ $cats[ $i - 1 ] }++;
            }
        }
    }

    # R session
    my $R = Statistics::R->new;

    $R->set( 'figfile', $opt->{outfile} );
    $R->set( 'fills',   \@fills );
    $R->set( 'alphas',  \@alphas );

    my $list_str = "";
    for my $i ( 1 .. $count ) {
        my @elements = grep { !/^#/ } App::Plotr::Common::read_first_column( $args->[ $i - 1 ] );
        $R->set( $cats[ $i - 1 ], \@elements );

        $list_str .= qq{"$cats[ $i - 1 ]" = $cats[ $i - 1 ], };
    }
    $list_str =~ s/,\s*$//;

    $R->run(q{ library(VennDiagram) });
    $R->run(q{ library(extrafont) });

    # suppress log files
    $R->run(q{ futile.logger::flog.threshold(futile.logger::ERROR, name = "VennDiagramLogger") });

    $R->run(
        qq{
        venn.plot <-
            venn.diagram(
                x = list($list_str),
                filename = NULL,
                fill = fills,
                alpha = alphas,
                fontfamily = "Arial",
                main.fontfamily = "Arial",
                sub.fontfamily = "Arial",
                cat.fontfamily = "Arial",
                print.mode = "@{[$opt->{percent} ? q{percent} : q{raw}]}",
                cex = 1.5,
                cat.cex = 2,
                cat.pos = 0
            )}    # Don't start a new line here
    );

    if ( $opt->{device} eq 'pdf' ) {
        $R->run(q{ pdf(file=figfile) });
    }
    elsif ( $opt->{device} eq 'png' ) {
        $R->run(q{ png(file=figfile) });
    }
    else {
        Carp::croak "Unrecognized device: [$opt->{device}]\n";
    }

    $R->run(q{ grid.draw(venn.plot) });
    $R->run(q{ dev.off() });

}

1;
