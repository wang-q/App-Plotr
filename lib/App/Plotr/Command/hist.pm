package App::Plotr::Command::hist;
use strict;
use warnings;
use autodie;

use App::Plotr -command;
use App::Plotr::Common;

sub abstract {
    return 'histogram';
}

sub opt_spec {
    return (
        [ "outfile|o=s",  "Output filename", ],
        [ "device=s",     "png or pdf", { default => "pdf" }, ],
        [ "xl=s",         "X label", ],
        [ "yl=s",         "Y label", ],
        [ "col|c=i",      "which column to count", { default => 1 }, ],
        [ "group|g=i",    "the group column", ],
        [ "bins=i",       "number of bins", { default => 30 }, ],
        [ "width=i",      "the width of bins", ],
        [ "proportion|p", "Y axis as proportions", ],
        [ "xmm=s",        "X min,max", ],
        [ "ymm=s",        "Y min,max", ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "plotr hist [options] <infile>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= <<'MARKDOWN';

* <infile> is a tab-separated file
    * By default, the first column is X, and the second column is the optional group.

* --outfile can't be stdout

* xl and yl can be plotmath

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
        plot_hist <- function (plotdata, plotmap) {
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
q{ pdf(file=figfile, family="Arial", width = 3, height = 3, useDingbats=FALSE) }
        );
    }
    elsif ( $opt->{device} eq 'png' ) {
        $R->run(
q{ png(file=figfile, family="Arial", width = 3, height = 3, units="in", res=200) }
        );
    }
    else {
        Carp::croak "Unrecognized device: [$opt->{device}]\n";
    }

    $R->run(q{ mydata <- read_tsv(file, col_names = TRUE) });

    # avoid aes_string which can't handle stat()
    $R->run(qq{ x <- names(mydata)[$opt->{col}] });
    my $x = $R->get('x');

    my $g = q{};
    if ( defined $opt->{group} ) {
        $R->run(qq{ g <- names(mydata)[$opt->{group}] });
        $g = $R->get('g');
    }

    if ( defined $opt->{group} ) {
        $R->run(qq{ mymap <- aes( x=$x, group=$g ) });
    }
    else {
        $R->run(qq{ mymap <- aes( x=$x ) });
    }
    $R->run(q{ plot <- plot_hist(mydata, mymap) });

    # bins and binwidth
    my @hist_opts = ();
    if ( defined $opt->{width} ) {
        push @hist_opts, qq{ binwidth=$opt->{width} };
    }
    elsif ( defined $opt->{bins} ) {
        push @hist_opts, qq{ bins=$opt->{bins} };
    }

    # group fills
    if ( defined $opt->{group} ) {
        push @hist_opts, q{ position="dodge" };
        if ( defined $opt->{proportion} ) {
            push @hist_opts,
              qq{ mapping=aes( fill=$g, y=stat(density * width) ) };
        }
        else {
            push @hist_opts, qq{ mapping=aes( fill=$g ) };
        }
    }
    else {
        push @hist_opts, qq{ color="white" };
        if ( defined $opt->{proportion} ) {
            push @hist_opts,
              qq{ mapping=aes( fill="indianred1", y=stat(density * width) ) };
        }
        else {
            push @hist_opts, qq{ mapping=aes(fill="indianred1") };
        }
    }
    my $hist_opt = join ",", @hist_opts;
    $R->run(qq{ plot <- plot + geom_histogram( $hist_opt ) });

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

    # if ( defined $opt->{style} ) {
    #     if ( $opt->{style} eq "blue" ) {
    #         $R->run(
    #             qq{
    #             plot <- plot +
    #             geom_line(colour="deepskyblue", size = 0.5) +
    #             geom_point(colour="deepskyblue", fill="white", shape=23) }
    #         );
    #     }
    #     elsif ( $opt->{style} eq "red" ) {
    #         $R->run(
    #             qq{
    #             plot <- plot +
    #             geom_line(colour="indianred", size = 0.5) +
    #             geom_point(colour="indianred", fill="white", shape=22) }
    #         );
    #     }
    # }

    $R->run(q{ print(plot) });
    $R->run(q{ dev.off() });

}

1;
