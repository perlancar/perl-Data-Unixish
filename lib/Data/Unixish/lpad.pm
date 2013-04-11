package Data::Unixish::lpad;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';

use Data::Unixish::_pad;

# VERSION

our %SPEC;

$SPEC{lpad} = {
    v => 1.1,
    summary => 'Pad text to the left until a certain column width',
    description => <<'_',

This function can handle text containing wide characters and ANSI escape codes.

Note: to pad to a certain character length instead of column width (note that
wide characters like Chinese can have width of more than 1 column in terminal),
you can turn of `mb` option even when your text contains wide characters.

_
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
        width => {
            schema => ['int*', min => 0],
            req => 1,
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
        char => {
            summary => 'Character to use for padding',
            schema => ['str*', len=>1, default=>' '],
            description => <<'_',

Character should have column width of 1. The default is space (ASCII 32).

_
            cmdline_aliases => { c => {} },
        },
        trunc => {
            summary => 'Whether to truncate text wider than specified width',
            schema => ['bool', default => 0],
        },
    },
    tags => [qw/format/],
};
sub lpad {
    my %args = @_;
    Data::Unixish::_pad::_pad("l", %args);
}

1;
# ABSTRACT: Pad text to the left until a certain column width

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 my @res = dux([lpad => {width=>6}], "123", "1234");
 # => ("   123", "  1234")

In command line:

 % echo -e "123\n1234" | dux lpad -w 6 -c x --format=text-simple
 xxx123
 xx1234

=cut
