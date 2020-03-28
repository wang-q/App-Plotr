use strict;
use warnings;
use Test::More;
use App::Cmd::Tester;

use App::Plotr;

my $result = test_app( 'App::Plotr' => [qw(help tree)] );
like( $result->stdout, qr{tree}, 'descriptions' );

$result = test_app( 'App::Plotr' => [qw(tree)] );
like( $result->error, qr{need .+input file}, 'need infile' );

$result = test_app( 'App::Plotr' => [qw(tree t/not_exists)] );
like( $result->error, qr{doesn't exist}, 'infile not exists' );

SKIP: {
    skip "R not installed",             2 unless IPC::Cmd::can_run('Rscript');
    skip "R package ape not installed", 2
        unless IPC::Cmd::run( command => q{ Rscript -e 'if(!require(ape)){ q(status = 1) }' } );
    skip "R package ape not installed", 2
        unless IPC::Cmd::run(
        command => q{ Rscript -e 'if(!require(extrafont)){ q(status = 1) }' } );

    my $t_path = Path::Tiny::path("t/")->absolute->stringify;
    my $cwd    = Path::Tiny->cwd;

    my $tempdir = Path::Tiny->tempdir;
    chdir $tempdir;

    test_app( 'App::Plotr' => [ "tree", "$t_path/YDL184C.nwk", "-o", "YDL184C.pdf", ] );
    ok( $tempdir->child("YDL184C.pdf")->is_file, 'pdf created' );

    Path::Tiny::path("$t_path/YDL184C.nwk")->copy("temp.nwk");
    test_app( 'App::Plotr' => [ "tree", "temp.nwk", "--device", "png", ] );
    ok( $tempdir->child("temp.nwk.png")->is_file, 'png with default name' );

    chdir $cwd;    # Won't keep tempdir
}

done_testing();
