package Module::ExtractUse;

use strict;
use warnings;

use Pod::Strip;
use Parse::RecDescent;
use Module::ExtractUse::Grammar;
use Carp;

use vars qw($VERSION);
$VERSION = '0.17';

#$::RD_TRACE=1;
#$::RD_HINT=1;

sub new {
    my $class=shift;
    return bless {
        found=>{},
        files=>0,
    },$class;
}

sub extract_use {
    my $self=shift;
    my $code_to_parse=shift;

    my $podless;
    my $pod_parser=Pod::Strip->new;
    $pod_parser->output_string(\$podless);
    if (ref($code_to_parse) eq 'SCALAR') {
        $pod_parser->parse_string_document($$code_to_parse);
    } else {
        $pod_parser->parse_file($code_to_parse);
    }

    # Strip obvious comments.
    $podless =~ s/^\s*#.*$//mg;

    # to keep parsing time short, split code in statements
    # (I know that this is not very exact, patches welcome!)
    my @statements=split(/;/,$podless);

    foreach my $statement (@statements) {
        $statement=~s/\n+/ /gs;
        my $result;

        # check for string eval
        $statement=~s/eval\s["'](.*?)["']/$1;/;
    
        # now that we've got some code containing 'use' or 'require',
        # parse it! (using different entry point to save some more
        # time)
        if ($statement=~/\buse/) {
            $statement=~s/^(.*?)use/use/;
            eval {
                my $parser=Module::ExtractUse::Grammar->new();
                $result=$parser->use($statement.';');
            };
        } elsif ($statement=~/\brequire/) {
            $statement=~s/^(.*?)require/require/;
            eval {
                my $parser=Module::ExtractUse::Grammar->new();
                $result=$parser->require($statement.';');
            };
        }

        next unless $result;

        foreach (split(/ /,$result)) {
            $self->_add($_);
        }
    }

    # increment file counter
    $self->_inc_files;

    return $self;
}


# Accessor Methods
sub _add {
    my $self=shift;
    my $found=shift;
    $self->{found}{$found}++;
}
sub _found { return shift->{found} }
sub _inc_files { shift->{files}++ }


# Accessor Methods
sub array { return keys(%{shift->{found}}) }
sub arrayref { 
    my @a=shift->array;
    return \@a if @a;
    return;
}

sub string {
    my $self=shift;
    my $sep=shift || ' ';
    return join($sep,sort keys(%{$self->{found}}));
}

sub used {
    my $self=shift;
    my $key=shift;
    return $self->{found}{$key} if ($key);
    return $self->{found};
}

sub files {
    return shift->{files};
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
  my $uses=$p->uses;           # $uses is a HASHREF
  print $p->uses('strict')     # true if code includes 'use strictt'
  my @uses=$p->array;
  my $uses=$p->string;


=head1 DESCRIPTION

Module::ExtractUse is basically a Parse::RecDescent grammar to parse
Perl code. It tries very hard to find all modules (whether pragmas,
Core, or from CPAN) used by the parsed code.

"Usage" is defined by either calling C<use> or C<require>.

=head2 Methods

=head3 new

Returns a parser object

=head3 extract_use

C<extract_use($code_to_parse)>

Runs the parser.

C<$code_to_parse> can be either a SCALAR, in which case
Module::ExtractUse tries to open the file specified in
$code_to_parse. Or a reference to a SCALAR, in which case
Module::ExtractUse assumes the referenced scalar contains the source
code.

The code will be stripped from POD (using Pod::Strip) and splitted on ";"
(semicolon). Each statement (i.e. the stuff between two semicolons) is
checked by a simple regular expression.

If the statement contains either 'use' or 'require', the statment is
handed over to the parser, who then tries to figure out, B<what> is
used or required. The results will be saved in a data structure that
you can examine afterwards.

You can call C<extract_use> several times on different files. It will
count how many files where examined and how often each module was used.

=head2 Accessor Methods

Those are various ways to get at the result of the parse.

Note that C<extract_use> returns the parser object, so you can say

  print $p->extract_use($code_to_parse)->string;

=head3 used

If called without an argument, returns a reference to an hash of all
used modules. Keys are the names of the modules, values are the number
of times they were used.

If called with an argument, looks up the value of the argument in the
hash and returns the number of times it was found during parsing.

This is the prefered accessor.

=head3 string

string($seperator)

Returns a sorted string of all used modules, joined using the value of
C<$seperator> or using a blank space as a default;

Module names are sorted by ascii value (i.e by C<sort>)

=head3 array

Returns an array of all used modules.

=head3 arrayref

Returns a reference to an array of all used modules. Surprise!

=head3 files

Returns the number of files parsed by the parser object.

=head1 RE-COMPILING THE GRAMMAR

If - for some reasons - you need to alter the grammar, edit the file
F<grammar> and afterwards run:

  perl -MParse::RecDescent - grammar Module::ExtractUse::Grammar

Make sure you're in the right directory, i.e. in F<.../Module/ExtractUse/>

=head1 EXPORTS

Nothing.

=head1 SEE ALSO

Parse::RecDescent, Module::ScanDeps, Module::Info, Module::CPANTS::Generator

=head1 AUTHOR

Thomas Klausner <domm@zsi.at>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-module-extractuse@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Module::ExtractUse is Copyright (c) 2003,2004,2005 ZSI,
Thomas Klausner. All rights reserved.

You may distribute under the same terms as Perl itself (Artistic
License)

=cut

