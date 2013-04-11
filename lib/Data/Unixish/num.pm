package Data::Unixish::num;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
use Number::Format;
use POSIX qw(locale_h);
use Scalar::Util 'looks_like_number';
use SHARYANTO::Number::Util qw(format_metric);

# VERSION

our %SPEC;

my %styles = (
    general    => 'General formatting, e.g. 1, 2.345',
    fixed      => 'Fixed number of decimal digits, e.g. 1.00, default decimal digits=2',
    scientific => 'Scientific notation, e.g. 1.23e+21',
    kilo       => 'Use K/M/G/etc suffix with base-2, e.g. 1.2M',
    kibi       => 'Use Ki/Mi/GiB/etc suffix with base-10 [1000], e.g. 1.2Mi',
    # XXX percent
    # XXX fraction
    # XXX currency?
);

# XXX negative number -X or (X)
# XXX colorize negative number?
# XXX leading zeros/spaces

$SPEC{num} = {
    v => 1.1,
    summary => 'Format number',
    description => <<'_',

Observe locale environment variable settings.

Undef and non-numbers are ignored.

_
    args => {
        %common_args,
        style => {
            schema=>['str*', in=>[keys %styles], default=>'general'],
            cmdline_aliases => { s=>{} },
            description => "Available styles:\n\n".
                join("", map {" * $_  ($styles{$_}\n"} sort keys %styles),
        },
        decimal_digits => {
            summary => 'Number of digits to the right of decimal point',
        },
        thousands_sep => {
            summary => 'Use a custom thousand separator character',
            description => <<'_',

Default is from locale (e.g. dot "." for en_US, etc).

Use empty string "" if you want to disable printing thousands separator.

_
            schema => ['str*'],
        },
        prefix => {
            summary => 'Add some string at the beginning (e.g. for currency)',
            schema => ['str*'],
        },
        suffix => {
            summary => 'Add some string at the end (e.g. for unit)',
            schema => ['str*'],
        },
    },
    tags => [qw/format/],
};
sub num {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $style = $args{style} // 'general';
    $style = 'general' if !$styles{$style};

    my $prefix  = $args{prefix} // "";
    my $suffix  = $args{suffix} // "";
    my $decdigs = $args{decimal_digits} //
        ($style eq 'kilo' || $style eq 'kibi' ? 1 : 2);

    my $orig_locale = setlocale(LC_ALL);
    if ($ENV{LC_NUMERIC}) {
        setlocale(LC_NUMERIC, $ENV{LC_NUMERIC});
    } elsif ($ENV{LC_ALL}) {
        setlocale(LC_ALL, $ENV{LC_ALL});
    } elsif ($ENV{LANG}) {
        setlocale(LC_ALL, $ENV{LANG});
    }

    my %nfargs;
    if (defined $args{thousands_sep}) {
        $nfargs{THOUSANDS_SEP} = $args{thousands_sep};
    }
    my $nf = Number::Format->new(%nfargs);

    while (my ($index, $item) = each @$in) {
        {
            last if !defined($item) || !looks_like_number($item);
            if ($style eq 'fixed') {
                $item = $nf->format_number($item, $decdigs, $decdigs);
            } elsif ($style eq 'scientific') {
                $item = sprintf("%.${decdigs}e", $item);
            } elsif ($style eq 'kilo') {
                my $res = format_metric(
                    $item, {base=>2, return_array=>1});
                $item = $nf->format_number($res->[0], $decdigs, $decdigs) .
                    $res->[1];
            } elsif ($style eq 'kibi') {
                my $res = format_metric(
                    $item, {base=>10, return_array=>1});
                $item = $nf->format_number($res->[0], $decdigs, $decdigs) .
                    $res->[1];
            } else {
                # general
                $item = $nf->format_number($item);
            }

            $item = "$prefix$item$suffix";
        }
        push @$out, $item;
    }

    setlocale(LC_ALL, $orig_locale);

    [200, "OK"];
}

1;
# ABSTRACT: Format number

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 my @res = dux([num => {style=>"fixed"}], 0, 10, -2, 34.5, [2], {}, "", undef);
 # => ("0.00", "10.00", "-2.00", "34.50", [2], {}, "", undef)

In command line:

 % echo -e "1\n-2\n" | LANG=id_ID dux num -s fixed --format=text-simple
 1,00
 -2,00

=cut
