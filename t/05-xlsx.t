use strict;
use warnings;
use Test::More;
use App::Cmd::Tester;

use App::Plotr;

my $result = test_app( 'App::Plotr' => [qw(help xlsx)] );
like( $result->stdout, qr{xlsx}, 'descriptions' );

$result = test_app( 'App::Plotr' => [qw(xlsx)] );
like( $result->error, qr{need .+input file}, 'need infile' );

$result = test_app( 'App::Plotr' => [qw(xlsx t/not_exists)] );
like( $result->error, qr{doesn't exist}, 'infile not exists' );

$result = test_app( 'App::Plotr' => [qw(xlsx t/formats.xlsx -o stdout)] );
is( ( scalar split( /\n/, $result->stdout ) ), 13, 'line count' );
like( ( split /\n/, $result->stdout )[0], qr{This workbook}, 'Skip empty lines' );

$result = test_app( 'App::Plotr' => [qw(xlsx t/formats.xlsx -s Borders -o stdout)] );
is( ( scalar split( /\n/, $result->stdout ) ), 37, 'line count' );
like( ( split /\n/, $result->stdout )[0], qr{Index\tIndex}, 'first line' );
like( ( split /\n/, $result->stdout )[1], qr{\t{5,}}, 'second line' );

done_testing();
