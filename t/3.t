#!/usr/bin/perl -w
use strict;
use Test::More tests=>3;
use Module::ExtractUse;



# test testfile
{
    my $p=Module::ExtractUse->new;
    my $used=$p->extract_use($0)->string(';');
    is ($used,'strict;Test::More;Module::ExtractUse');
}

# test Module::ExtractUse
{
    my $p=Module::ExtractUse->new;
    my $used=$p->extract_use('ExtractUse.pm')->string;
    is($used,'5.006 strict warnings Pod::Simple Parse::RecDescent Module::ExtractUseGrammar vars');
}


# test Module::ExtractUse for strictness
{
    my $p=Module::ExtractUse->new;
    my $used=$p->extract_use('ExtractUse.pm')->hashref;
    is($used->{'strict'},1);
}



