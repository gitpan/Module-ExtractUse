#!/usr/bin/perl -w
use strict;
use Test::More;

use Module::ExtractUse;


my @tests=
  (
   ['useSome::Module1;',undef],
   ['use Some::Module2;','Some::Module2'],
   ["yadda yadda useless stuff;".'use Some::Module3 qw/$VERSION @EXPORT @EXPORT_OK/;','Some::Module3'],
   ['use base qw(Class::DBI4 Foo::Bar5);','Class::DBI4 Foo::Bar5'],
   ['if ($foo) { use Foo::Bar6; }','Foo::Bar6'],
   ['use constant dl_ext => ".$Config{dlext}";','constant'],
   ['use strict;','strict'],

   ['use Foo8 qw/asdfsdf/;','Foo8'],
   ['$use=stuff;',undef],
   ['abuse Stuff;',undef],
   ['package Module::ScanDeps;',undef],
   ['if ($foo) { require "Bar7"; }','Bar7'],#
   ['require "some/stuff.pl";',undef],
   ['require "Foo/Bar.pm9";','Foo::Bar9'],#
   ['require Foo10;','Foo10'],

   ["use Some::Module11;use Some::Other::Module12;",'Some::Module11 Some::Other::Module12'],
   ["use Some::Module;\nuse Some::Other::Module;",'Some::Module Some::Other::Module'],
   ['use vars qw/$VERSION @EXPORT @EXPORT_OK/;','vars'],
   ['unless ref $obj;  # use ref as $obj',undef],
   ['$self->_carp("$name trigger deprecated: use before_$name or after_$name instead");',undef],
   ["use base 'Exporter1';",'Exporter1'],
   ['use base ("Class::DBI2");','Class::DBI2'],
   ['use base "Class::DBI3";','Class::DBI3'],
   ['use base qw/Class::DBI4 Foo::Bar5/;','Class::DBI4 Foo::Bar5'],
   ['use base ("Class::DBI6","Foo::Bar7");','Class::DBI6 Foo::Bar7'],
   ['use base "Class::DBI8","Foo::Bar9";','Class::DBI8 Foo::Bar9'],
  );


plan tests => scalar @tests;


foreach my $t (@tests) {
    my ($code,$expected)=@$t;
    my $p=Module::ExtractUse->new;
    my $used=$p->extract_use(\$code)->string;
    if ($used) {
	is($used,$expected,'');
    } else {
	is(undef,$expected,'');
    }
}


__DATA__


