use strict;
use Module::Build;
use File::Spec::Functions;

my $build = Module::Build->new
  (
   module_name => 'Module::ExtractUse',
   license     => 'perl',
   requires    => {
		   'Parse::RecDescent'=>'1.94',
		   'Pod::Simple'=>'3.00',
		   'Test::More'=>'0',
		   'Test::Deep'=>'0.087',
		  },
   create_makefile_pl=>'passthrough',
);

$build->create_build_script;
