use Test::More tests => 2;

use strict;
use warnings;

use Module::ExtractUse;

my $semi   = 'eval "use Test::Pod 1.00;";';
my $nosemi = "eval 'use Test::Pod 1.00';";

my $p = Module::ExtractUse->new;
$p->extract_use( \$semi );

ok( $p->used( 'Test::Pod' ) );

$p = Module::ExtractUse->new;
$p->extract_use( \$nosemi );

ok( $p->used( 'Test::Pod' ) );

