package App::Plotr::Command::lines;
use strict;
use warnings;
use autodie;

use App::Plotr -command;
use App::Plotr::Common;

sub abstract {
    return 'scatter lines';
}

sub opt_spec {
    return (
        [ "outfile|o=s", "Output filename", ],
        [ "device=s",    "png or pdf",         { default => "pdf" }, ],
        [ "font=s",      "Arial or Helvetica", { default => "Arial" }, ],
        [ "xl=s",         "X label", ],
        [ "yl=s",         "Y label", ],
        [ "xmm=s",       "X min,max", ],
        [ "ymm=s",       "Y min,max", ],
        [ "style=s",     "blue, red", ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "plotr lines [options] <infile>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= <<'MARKDOWN';

* <infile> is a tab-separated file
    * The first column is X, the second column is Y, and the third column is the group.

* --outfile can't be stdout

* xl and yl can be plotmath

    --xl "Distance to indels ({italic(d)[1]})"

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
        $opt->{outfile} =
          Path::Tiny::path( $args->[0] )->absolute . ".$opt->{device}";
    }

}

sub execute {
    my ( $self, $opt, $args ) = @_;

    # R session
    my $R = Statistics::R->new;

    $R->set( 'file',    $args->[0] );
    $R->set( 'figfile', $opt->{outfile} );

    # library
    $R->run(q{ library(readr) });
    $R->run(q{ library(ggplot2) });
    $R->run(q{ library(scales) });
    $R->run(q{ library(extrafont) });

    $R->run(
        qq{
        plot_line <- function (plotdata, plotmap) {
            plot <- ggplot(data=plotdata, mapping=plotmap) +
                theme_bw(base_size = 10) +
                guides(fill="none") +
                theme(panel.grid.major.x = element_blank(), panel.grid.major.y = element_blank()) +
                theme(panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank())
            return(plot)
        } }
    );

    # device
    if ( $opt->{device} eq 'pdf' ) {
        $R->run(
qq{ pdf(file=figfile, family="$opt->{font}", width = 3, height = 3, useDingbats=FALSE) }
        );
    }
    elsif ( $opt->{device} eq 'png' ) {
        $R->run(
qq{ png(file=figfile, family="$opt->{font}", width = 3, height = 3, units="in", res=200) }
        );
    }
    else {
        Carp::croak "Unrecognized device: [$opt->{device}]\n";
    }

    $R->run(q{ mydata <- read_tsv(file, col_names = TRUE) });

    # avoid aes_string which can't handle stat()
    $R->run(qq{ x <- names(mydata)[1] });
    my $x = $R->get('x');
    $R->run(qq{ y <- names(mydata)[2] });
    my $y = $R->get('y');
    $R->run(qq{ g <- names(mydata)[3] });
    my $g = $R->get('g');

    $R->run(qq{ mymap <- aes( x=$x, y=$y, group=$g ) });
    $R->run(q{ plot <- plot_line(mydata, mymap) });

    # line and point
    if ( defined $opt->{style} ) {
        if ( $opt->{style} eq "blue" ) {
            $R->run(
                qq{
                plot <- plot +
                    geom_line(colour="deepskyblue", size = 0.5) +
                    geom_point(colour="deepskyblue", fill="white", shape=23, size=1) }
            );
        }
        elsif ( $opt->{style} eq "red" ) {
            $R->run(
                qq{
                plot <- plot +
                    geom_line(colour="indianred", size = 0.5) +
                    geom_point(colour="indianred", fill="white", shape=22, size=1) }
            );
        }
    }
    else {
        $R->run(
            qq{
            plot <- plot +
                geom_line(colour="grey", size = 0.5) +
                geom_point(colour="grey", fill="grey", shape=21, size=1) }
        );
    }

    # plotmath need to be escaped
    if ( defined $opt->{xl} ) {
        if ( $opt->{xl} =~ /^(.*)(\{.+\})(.*)$/ ) {
            my $lab_pre  = $1;
            my $lab_exp  = $2;
            my $lab_post = $3;
            my $eval_code =
qq{eval(parse( text = \"x_lab <- expression(paste(\\\"$lab_pre\\\", $lab_exp, \\\"$lab_post\\\"))\" ))};
            $R->run($eval_code);
        }
        else {
            $R->set( 'x_lab', $opt->{xl} );
        }
        $R->run(q{ plot <- plot + xlab(x_lab) });
    }

    if ( defined $opt->{yl} ) {
        if ( $opt->{yl} =~ /^(.*)(\{.+\})(.*)$/ ) {
            my $lab_pre  = $1;
            my $lab_exp  = $2;
            my $lab_post = $3;
            my $eval_code =
qq{eval(parse( text = \"y_lab <- expression(paste(\\\"$lab_pre\\\", $lab_exp, \\\"$lab_post\\\"))\" ))};
            $R->run($eval_code);
        }
        else {
            $R->set( 'y_lab', $opt->{yl} );
        }
        $R->run(q{ plot <- plot + ylab(y_lab) });
    }

    # xmm and ymm
    if ( defined $opt->{xmm} ) {
        $R->run(qq{ plot <- plot + scale_x_continuous(limits=c($opt->{xmm})) });
    }
    else {
        $R->run(qq{ plot <- plot + scale_x_continuous() });
    }

    if ( defined $opt->{ymm} ) {
        $R->run(qq{ plot <- plot + scale_y_continuous(limits=c($opt->{ymm})) });
    }
    else {
        $R->run(qq{ plot <- plot + scale_y_continuous() });
    }

    $R->run(q{ print(plot) });
    $R->run(q{ dev.off() });

}

1;
