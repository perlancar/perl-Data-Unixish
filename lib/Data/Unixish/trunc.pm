package Data::Unixish::trunc;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
use Text::ANSI::Util qw(ta_trunc ta_mbtrunc);
use Text::WideChar::Util qw(mbtrunc);

# VERSION

our %SPEC;

$SPEC{trunc} = {
    v => 1.1,
    summary => 'Truncate string to a certain column width',
    description => <<'_',

This function can handle text containing wide characters and ANSI escape codes.

Note: to truncate by character instead of column width (note that wide
characters like Chinese can have width of more than 1 column in terminal), you
can turn of `mb` option even when your text contains wide characters.

_
    args => {
        %common_args,
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
    },
    tags => [qw/format/],
};
sub trunc {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $w    = $args{width};
    my $ansi = $args{ansi};
    my $mb   = $args{mb};

    while (my ($index, $item) = each @$in) {
        {
            last if !defined($item) || ref($item);
            if ($ansi) {
                if ($mb) {
                    $item = ta_mbtrunc($item, $w);
                } else {
                    $item = ta_trunc($item, $w);
                }
            } elsif ($mb) {
                $item = mbtrunc($item, $w);
            } else {
                $item = substr($item, 0, $w);
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

 use Data::Unixish qw(lduxl);
 my @res = lduxl([trunc => {width=>4}], "123", "1234", "12345"); # => ("123", "1234", "1234")

In command line:

 % echo -e "123\n1234\n12345" | dux trunc -w 4 --format=text-simple
 123
 1234
 1234

=cut
