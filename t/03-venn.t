use strict;
use warnings;
use Test::More;
use App::Cmd::Tester;

use App::Plotr;

my $result = test_app( 'App::Plotr' => [qw(help venn)] );
like( $result->stdout, qr{venn}, 'descriptions' );

$result = test_app( 'App::Plotr' => [qw(venn)] );
like( $result->error, qr{need .+input file}, 'need infile' );

$result = test_app( 'App::Plotr' => [qw(venn t/not_exists)] );
like( $result->error, qr{doesn't exist}, 'infile not exists' );

SKIP: {
    skip "R not installed", 1 unless IPC::Cmd::can_run('Rscript');
    skip "R package ape not installed", 1
        unless IPC::Cmd::run(
        command => q{ Rscript -e 'if(!require(VennDiagram)){ q(status = 1) }' } );
    skip "R package ape not installed", 1
        unless IPC::Cmd::run(
        command => q{ Rscript -e 'if(!require(extrafont)){ q(status = 1) }' } );

    my $t_path = Path::Tiny::path("t/")->absolute->stringify;
    my $cwd    = Path::Tiny->cwd;

    my $tempdir = Path::Tiny->tempdir;
    chdir $tempdir;

    test_app(
        'App::Plotr' => [
            "venn",                   "$t_path/rocauc.result.tsv",
            "$t_path/mcox.05.result.tsv", "-o",
            "venn.pdf",
        ]
    );
    ok( $tempdir->child("venn.pdf")->is_file, 'pdf created' );

    chdir $cwd;    # Won't keep tempdir
}

done_testing();
