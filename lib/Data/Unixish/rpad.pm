package Data::Unixish::rpad;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';

use SHARYANTO::String::Util qw(pad);
use Text::ANSI::Util qw(ta_pad ta_mbpad);
use Text::WideChar::Util qw(mbpad);

# VERSION

our %SPEC;

$SPEC{rpad} = {
    v => 1.1,
    summary => 'Pad text to the right until a certain column width',
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
sub rpad {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $w     = $args{width};
    my $ansi  = $args{ansi};
    my $mb    = $args{mb};
    my $char  = $args{padchar} // " ";
    my $trunc = $args{trunc};

    while (my ($index, $item) = each @$in) {
        {
            last if !defined($item) || ref($item);
            if ($ansi) {
                if ($mb) {
                    $item = ta_mbpad($item, $w, "r", $char, $trunc);
                } else {
                    $item = ta_pad  ($item, $w, "r", $char, $trunc);
                }
            } elsif ($mb) {
                $item = mbpad($item, $w, "r", $char, $trunc);
            } else {
                $item = pad  ($item, $w, "r", $char, $trunc);
            }
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Truncate string to a certain column width

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::trunc;
 my $in  = ["123", "1234", "12345"];
 my $out = [];
 Data::Unixish::trunc::trunc(in=>$in, out=>$out, width=>4);
 # $out = ["123", "1234", "1234"]

In command line:

 % echo -e "123\n1234\n12345" | dux trunc -w 4 --format=text-simple
 123
 1234
 1234

=cut

