use strict;
use warnings;
use Test::More;
use App::Cmd::Tester;

use App::Plotr;

my $result = test_app( 'App::Plotr' => [qw(help lines)] );
like( $result->stdout, qr{lines}, 'descriptions' );

$result = test_app( 'App::Plotr' => [qw(lines)] );
like( $result->error, qr{need .+input file}, 'need infile' );

$result = test_app( 'App::Plotr' => [qw(lines t/not_exists)] );
like( $result->error, qr{doesn't exist}, 'infile not exists' );

SKIP: {
    skip "R not installed",             1 unless IPC::Cmd::can_run('Rscript');
    skip "R package ape not installed", 1
        unless IPC::Cmd::run(
        command => q{ Rscript -e 'if(!require(ggplot2)){ q(status = 1) }' } );
    skip "R package ape not installed", 1
        unless IPC::Cmd::run(
        command => q{ Rscript -e 'if(!require(extrafont)){ q(status = 1) }' } );

    my $t_path = Path::Tiny::path("t/")->absolute->stringify;
    my $cwd    = Path::Tiny->cwd;

    my $tempdir = Path::Tiny->tempdir;
    chdir $tempdir;

    test_app(
        'App::Plotr' => [
            "lines", "$t_path/d1.tsv", "-o", "lines.pdf",
        ]
    );
    ok( $tempdir->child("lines.pdf")->is_file, 'pdf created' );

    chdir $cwd;    # Won't keep tempdir
}

done_testing();
