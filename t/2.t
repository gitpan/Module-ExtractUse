#!/usr/bin/perl -w
use strict;
use Test::More;

use Module::ExtractUse;


my @tests=
  (
   ['useSome::Module;',undef],
   ['use Some::Module;','Some::Module'],
   ["yadda yadda useless stuff;\n".'use Some::Module qw/$VERSION @EXPORT @EXPORT_OK/;','Some::Module'],
   ['use base qw(Class::DBI Foo::Bar);','Class::DBI Foo::Bar'],
   ['if ($foo) { use Foo::Bar; }','Foo::Bar'],
   ['use constant dl_ext => ".$Config{dlext}";','constant'],
   ['use strict;','strict'],
   ['if ($foo) { require "Bar"; }','Bar'],
   ['use Foo qw/asdfsdf/;','Foo'],
   ['$use=stuff;',undef],
   ['abuse Stuff;',undef],
   ['package Module::ScanDeps;',undef],

   ['require "some/stuff.pl";',undef],
   ['require "Foo/Bar.pm";','Foo::Bar'],
   ['require Foo;','Foo'],

   ["use Some::Module;use Some::Other::Module;",'Some::Module Some::Other::Module'],
   ["use Some::Module;\nuse Some::Other::Module;",'Some::Module Some::Other::Module'],
   ['use vars qw/$VERSION @EXPORT @EXPORT_OK/;','vars'],
   ['unless ref $obj;  # use ref as $obj',undef],
   ['$self->_carp("$name trigger deprecated: use before_$name or after_$name instead");',undef],
   ["use base 'Exporter';",'Exporter'],
   ['use base ("Class::DBI");','Class::DBI'],
   ['use base "Class::DBI";','Class::DBI'],
   ['use base qw/Class::DBI Foo::Bar/;','Class::DBI Foo::Bar'],
   ['use base ("Class::DBI","Foo::Bar");','Class::DBI Foo::Bar'],
   ['use base "Class::DBI","Foo::Bar";','Class::DBI Foo::Bar'],
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


