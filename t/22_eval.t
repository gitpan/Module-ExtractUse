use Test::More tests => 4;

use strict;
use warnings;

use Module::ExtractUse;

{
    my $semi   = 'eval "use Test::Pod 1.00;";';
    my $p = Module::ExtractUse->new;
    $p->extract_use( \$semi );

    ok( $p->used( 'Test::Pod' ) );
}

{
    my $nosemi = "eval 'use Test::Pod 1.00';";
    my $p = Module::ExtractUse->new;
    $p->extract_use( \$nosemi );

    ok( $p->used( 'Test::Pod' ) );
}

# reported by DAGOLDEN@cpan.org as [rt.cpan.org #19302]
{
    my $varversion = q{my $ver=1.22;
eval "use Test::Pod $ver;"};
    my $p = Module::ExtractUse->new;
    $p->extract_use( \$varversion );

    ok( $p->used( 'Test::Pod' ) );
}

{
    my $varversion = q{my $ver=1.22;
eval 'use Test::Pod $ver';};
    my $p = Module::ExtractUse->new;
    $p->extract_use( \$varversion );

    ok( $p->used( 'Test::Pod' ) );
}


