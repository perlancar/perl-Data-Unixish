package Data::Unixish::rins;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{rins} = {
    v => 1.1,
    summary => 'Add some text at the end of each line of text',
    description => <<'_',

This is sort of a counterpart for rtrim, which removes whitespace at the end
(right) of each line of text.

_
    args => {
        %common_args,
        text => {
            summary => 'The text to add',
            schema  => ['str*'],
            req     => 1,
            pos     => 0,
        },
    },
    tags => [qw/text/],
};
sub rins {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $text = $args{text};

    while (my ($index, $item) = each @$in) {
        my @lt;
        if (defined($item) && !ref($item)) {
            $item =~ s/$/$text/mg;
        }

        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Add some text at the end of each line of text

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(aduxa);
 my @res = aduxa([rins => {text=>"xx"}, "a", "b ", "c\nd ", undef, ["e"]);
 # => ("axx", "b xx", "cxx\nd xx", undef, ["e"])

In command line:

 % echo -e "1\n2 " | dux rins --text xx
 1xx
 2 xx

=cut
