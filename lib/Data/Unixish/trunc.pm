package Data::Unixish::trunc;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
use Text::ANSI::Util qw(ta_trunc);
use Text::ANSI::WideUtil qw(ta_mbtrunc);
use Text::WideChar::Util qw(mbtrunc);

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

$SPEC{trunc} = {
    v => 1.1,
    summary => 'Truncate string to a certain column width',
    description => <<'MARKDOWN',

This function can handle text containing wide characters and ANSI escape codes.

Note: to truncate by character instead of column width (note that wide
characters like Chinese can have width of more than 1 column in terminal), you
can turn of `mb` option even when your text contains wide characters.

MARKDOWN
    args => {
        %common_args,
        width => {
            schema => ['int*', min => 0],
            req => 1,
            pos => 0,
            cmdline_aliases => { w => {} },
        },
        ansi => {
            summary => 'Whether to handle ANSI escape codes',
            schema => ['bool', default => 0],
        },
        mb => {
            summary => 'Whether to handle wide characters',
            schema => ['bool', default => 0],
        },
    },
    tags => [qw/itemfunc text/],
};
sub trunc {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        push @$out, _trunc_item($item, \%args);
    }

    [200, "OK"];
}

sub _trunc_item {
    my ($item, $args) = @_;
    return $item if !defined($item) || ref($item);
    if ($args->{ansi}) {
        if ($args->{mb}) {
            return ta_mbtrunc($item, $args->{width});
        } else {
            return ta_trunc($item, $args->{width});
        }
    } elsif ($args->{mb}) {
        return mbtrunc($item, $args->{width});
    } else {
        return substr($item, 0, $args->{width});
    }
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl([trunc => {width=>4}], "123", "1234", "12345"); # => ("123", "1234", "1234")

In command line:

 % echo -e "123\n1234\n12345" | dux trunc -w 4 --format=text-simple
 123
 1234
 1234

=cut
