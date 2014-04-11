package MyModuleBuilder;
use Module::Build;
@ISA = qw(Module::Build);
use File::Copy;
use File::Spec::Functions;
sub process_grammar_files {
    my $self = shift;
    my $grammar='Grammar.pm';

    # precompile grammar
    system("$^X -MParse::RecDescent - grammar Module::ExtractUse::Grammar");

    # add $VERSION to grammer
    open(my $fh,'<',$grammar) || die "cannot read $grammar: $!";
    my @content = <$fh>;
    close $fh;
    splice(@content,1,0,'our $VERSION=##{$version##};'."\n");
    open(my $out,">",$grammar) || die "cannot write $grammer: $!";
    print $out @content;
    close $out;

    # move Grammer.pm to right place
    my $target = catfile(qw(lib Module ExtractUse),$grammar);
    move($grammar, $target) || die "Could not move precompiled $grammar to lib/Module/ExtractUse/Grammer.pm: $!";
}


1;
