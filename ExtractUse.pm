package Module::ExtractUse;

use 5.006;
use strict;
use warnings;

use base 'Pod::Simple';  # for the POD-removing hack
use Parse::RecDescent;
use Module::ExtractUseGrammar;

use vars qw($VERSION);
$VERSION = '0.10';

#$::RD_TRACE=1;
#$::RD_HINT=1;

sub new {
    my $class=shift;
    return bless
      {
       found=>undef
      },$class;
}

sub extract_use {
    my $self=shift;
    my $module=shift;

    # remove POD - this is a hack
    # as soon as there is Pod::Simple::Remove, this will be replaced by
    # it.
    my $podless;
    my $pod_parser=__PACKAGE__->_pod_remover();
    $pod_parser->output_string(\$podless);
    if (ref($module) eq 'SCALAR') {
	$pod_parser->parse_string_document($$module);
    } else {
	$pod_parser->parse_file($module);
    }

    # to keep parsing time short, split code in statements
    # (I know that this is not very exact, patches welcome!)
    my @statements=split(/;/,$podless);
    my @found;
    foreach my $statement (@statements) {
	$statement=~s/\n+/ /gs;
	my $result;

	# now that we've got some code containing 'use' or 'require',
	# parse it! (using different entry point to save some more
	# time)
	if ($statement=~/\buse/) {
	    $statement=~s/^(.*?)use/use/;
	    my $parser=Module::ExtractUseGrammar->new();
	    $result=$parser->use($statement.";");

	} elsif ($statement=~/\brequire/) {
	    $statement=~s/^(.*?)require/require/;
	    my $parser=Module::ExtractUseGrammar->new();
	    $result=$parser->require($statement.";");

	} else {
	    next;
	}

	push(@found,split(/ /,$result)) if $result;
    }

    $self->{'found'}=\@found;
    return $self;
}

# this should be Pod::Simple::Remove
# returns a Pod::Simple Object
sub _pod_remover {
    my $new = shift->SUPER::new(@_);
    $new->code_handler
      (
       sub {
	   print {$_[2]{'output_fh'}} $_[0], "\n";
	   return;
       });
    return $new;
}



# Accessor Methods
sub _found { return shift->{'found'} }

sub array { return @{shift->_found} }
sub arrayref { return shift->_found }

sub string {
    my $self=shift;
    my $sep=shift || ' ';
    return join($sep,@{$self->_found});
}

sub hashref {
    my $self=shift;
    my $found;
    foreach ($self->array) {
	$found->{$_}++;
    }
    return $found;
}



1;


__END__

=head1 NAME

Module::ExtractUse - Find out what modules are used

=head1 SYNOPSIS

  use Module::ExtractUse;
  
  # get a parser
  my $p=Module::ExtractUse->new;
  
  # parse from a file
  $p->extract_use('/path/to/module.pm');
  
  # or parse from a ref to a string in memory
  $p->extract_use(\$string_containg_code);
  
  # use some reporting methods
  my @uses=$p->array;
  my $uses=$p->string;


=head1 DESCRIPTION

Module::ExtractUse is basically a Parse::RecDescent grammar to parse
Perl code. It tries very hard to find all modules (whether pragmas,
Core, or from CPAN) used by the parsed code.

"Usage" is defined by either calling C<use> or C<require>.

=head2 Methods

=over

=item *

C<new>

Returns a parser object

=item *

C<extract_use($module)>

Runs the parser.

C<$module> can be either a SCALAR, in which case Module::ExtractUse
tries to open the file specified in $module. Or a reference to a
SCALAR, in which case Module::ExtractUse assumes the referenced scalar
contains the source code.

The code will be stripped from POD (using a quickly hacked POD-Remover
based on Pod::Simple, that should go away as soon as this hack is
included in Pod::Simple) and splitted on ";" (semicolon). Each
statement (i.e. the stuff between two semicolons) is checked by a
simple regular expression.

If the statement contains either 'use' or 'require', the statment is
handed over to the parser, who then tries to figure out, B<what> is
used or required. The results will be saved in a data structure that
you can then examine.


=back

=head2 Accessor Methods

Those are various ways to get at the result of the parse.

Note that C<extract_use> returns the parser object, so you can say

  print $p->extract_use($module)->string;

=over

=item *

C<string($seperator)>

Returns a string of all used modules, joined using the value of
C<$seperator> or using a blank space as a default;

=item *

C<array>

Returns an array of all used modules.

=item *

C<arrayref>

Returns a reference to an array of all used modules. Surprise!

=item *

C<hashref>

Returns a reference to an hash of all used modules.

Keys are the names of the modules, values are the number of times they
were used.

=back

=head1 RE-COMPILING THE GRAMMAR

If - for some reasons - you need to alter the grammar, edit the file
F<grammar> and afterwards run:

  perl -MParse::RecDescent - grammar Module::ExtractUseGrammar

=head2 EXPORTS

Nothing.

=head1 SEE ALSO

Parse::RecDescent, Module::ScanDeps, Module::Info

=head1 AUTHOR

Thomas Klausner <domm@zsi.at>

=head1 COPYRIGHT

Module::ExtractUse is Copyright (c) 2003 ZSI, Thomas Klausner. All
rights reserved.

You may distribute under the same terms as Perl itself (Artistic
License)

=cut

