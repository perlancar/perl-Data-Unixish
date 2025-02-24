package Data::Unixish::centerpad;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::_pad;
use Data::Unixish::Util qw(%common_args);

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

$SPEC{centerpad} = {
    v => 1.1,
    summary => 'Center text to a certain column width',
    description => <<'MARKDOWN',

This function can handle text containing wide characters and ANSI escape codes.

Note: to center to a certain character length instead of column width (note that
wide characters like Chinese can have width of more than 1 column in terminal),
you can turn of `mb` option even when your text contains wide characters.

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
        char => {
            summary => 'Character to use for padding',
            schema => ['str*', len=>1, default=>' '],
            description => <<'MARKDOWN',

Character should have column width of 1. The default is space (ASCII 32).

MARKDOWN
            cmdline_aliases => { c => {} },
        },
        trunc => {
            summary => 'Whether to truncate text wider than specified width',
            schema => ['bool', default => 0],
        },
    },
    tags => [qw/itemfunc text/],
};
sub centerpad {
    my %args = @_;
    Data::Unixish::_pad::_pad("c", %args);
}

sub _centerpad_begin { Data::Unixish::_pad::__pad_begin('c', @_) }
sub _centerpad_item { Data::Unixish::_pad::__pad_item('c', @_) }

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl([centerpad => {width=>6}], "123", "1234"); # => (" 123  ", " 1234 ")

In command line:

 % echo -e "123\n1234" | dux centerpad -w 10 -c x --format=text-simple
 xxx123xxxx
 xxx1234xxx

=cut
