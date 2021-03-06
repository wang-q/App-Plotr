package App::Plotr::Command::tree;
use strict;
use warnings;
use autodie;

use App::Plotr -command;
use App::Plotr::Common;

sub abstract {
    return 'draw newick trees';
}

sub opt_spec {
    return (
        [ "outfile|o=s", "Output filename", ],
        [ "device=s", "png or pdf", { default => "pdf" }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "plotr tree [options] <infile>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= <<'MARKDOWN';

* <infile> is a newick file (*.nwk)
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

    my $R = Statistics::R->new;

    $R->set( 'datafile', $args->[0] );
    $R->set( 'figfile',  $opt->{outfile} );

    $R->run(q{ library(ape) });
    $R->run(q{ library(extrafont) });
    $R->run(
        q{
        plot_tree <- function(tree) {
            barlen <- min(max(tree$edge.length)-mean(tree$edge.length), 0.1)
            if (barlen < 0.01) {
                barlen <- 0.005
            } else if (barlen < 0.1) {
                barlen <- 0.01
            }
            tree <- ladderize(tree)
            plot.phylo(
                tree,
                cex = 0.8,
                font = 1,
                adj = 0,
                xpd = TRUE,
                label.offset = 0.001,
                no.margin = TRUE,
                underscore = TRUE
            )
            nodelabels(
                tree$node.label,
                adj = c(1.3,-0.5),
                frame = "n",
                cex = 0.8,
                font = 3,
                xpd = TRUE
            )
            add.scale.bar(
                x = 0,
                y = 0.85,
                cex = 0.8,
                lwd = 2,
                length = barlen
            )
        }}    # Don't start a new line here
    );
    $R->run(q{ tree <- read.tree(datafile) });
    $R->run(q{ count <- length(tree$tip.label) });

    if ( $opt->{device} eq 'pdf' ) {
        $R->run(q{ pdf(file=figfile, family="Arial", width = 4, height = 4 * count/16, useDingbats=FALSE) });
    }
    elsif ( $opt->{device} eq 'png' ) {
        $R->run(q{ png(file=figfile, family="Arial", width = 4, height = 4 * count/16, units="in", res=200) });
    }
    else {
        Carp::croak "Unrecognized device: [$opt->{device}]\n";
    }

    $R->run(q{ plot_tree(tree) });
    $R->run(q{ dev.off() });
}

1;
