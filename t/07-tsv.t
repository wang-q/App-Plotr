use strict;
use warnings;
use Test::More;
use App::Cmd::Tester;

use App::Plotr;

my $result = test_app( 'App::Plotr' => [qw(help tsv)] );
like( $result->stdout, qr{tsv}, 'descriptions' );

$result = test_app( 'App::Plotr' => [qw(tsv)] );
like( $result->error, qr{need .+input file}, 'need infile' );

$result = test_app( 'App::Plotr' => [qw(tsv t/not_exists)] );
like( $result->error, qr{doesn't exist}, 'infile not exists' );

{
    my $t_path = Path::Tiny::path("t/")->absolute->stringify;
    my $cwd    = Path::Tiny->cwd;

    my $tempdir = Path::Tiny->tempdir;
    chdir $tempdir;

    test_app( 'App::Plotr' => [ "tsv", "$t_path/mcox.05.result.tsv", "-o", "mcox.xlsx", ] );
    ok( $tempdir->child("mcox.xlsx")->is_file, 'xlsx created' );

    my $xlsx  = Spreadsheet::XLSX->new( $tempdir->child("mcox.xlsx")->stringify );
    my $sheet = $xlsx->{Worksheet}[0];

    is( $sheet->{Name},             "mcox.05.result", "Sheet Name" );
    is( $sheet->{MaxRow},           2040 - 1,         "Sheet MaxRow" );
    is( $sheet->{MaxCol},           3 - 1,            "Sheet MaxCol" );
    is( $sheet->{Cells}[0][0]{Val}, "#marker",        "Cell content 1" );

    test_app(
        'App::Plotr' => [
            "tsv", "$t_path/rocauc.result.tsv", "-o", "rocauc.xlsx",
            "--le", "4:0.5", "--ge", "4:0.6", "--bt", "4:0.52:0.58", "--contain", "2:m03",
        ]
    );
    ok( $tempdir->child("rocauc.xlsx")->is_file, 'xlsx created' );

    chdir $cwd;    # Won't keep tempdir
}

done_testing();
