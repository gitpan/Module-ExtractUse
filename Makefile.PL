use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.


{
    use Parse::RecDescent;
    open GRAMMAR_FILE, "grammar" or die;
    local $/;
    my $grammar = <GRAMMAR_FILE>;
    Parse::RecDescent->Precompile($grammar, "Module::ExtractUseGrammar");
}


WriteMakefile(
    'NAME'		=> 'Module::ExtractUse',
    'VERSION_FROM'	=> 'ExtractUse.pm', # finds $VERSION
    'PREREQ_PM'		=> {
			    Parse::RecDescent=>0,
			    Pod::Simple=>0,
			   },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'ExtractUse.pm', # retrieve abstract from module
       AUTHOR     => 'Thomas Klausner <domm@zsi.at>') : ()),
);
