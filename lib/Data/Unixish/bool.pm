package Data::Unixish::bool;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use utf8;
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

sub _is_true {
    my ($val, $notion) = @_;

    if ($notion eq 'n1') {
        return undef unless defined($val);
        return 0 if ref($val) eq 'ARRAY' && !@$val;
        return 0 if ref($val) eq 'HASH'  && !keys(%$val);
        return $val ? 1:0;
    } else {
        # perl
        return undef unless defined($val);
        return $val ? 1:0;
    }
}

my %styles = (
    one_zero          => ['1', '0'],
    t_f               => ['t', 'f'],
    true_false        => ['true', 'false'],
    y_n               => ['y', 'n'],
    Y_N               => ['Y', 'N'],
    yes_no            => ['yes', 'no'],
    v_X               => ['v', 'X'],
    check             => ['✓', ' ', 'uses Unicode'],
    check_cross       => ['✓', '✕', 'uses Unicode'],
    heavy_check_cross => ['✔', '✘', 'uses Unicode'],
    dot               => ['●', ' ', 'uses Unicode'],
    dot_cross         => ['●', '✘', 'uses Unicode'],

);

$SPEC{bool} = {
    v => 1.1,
    summary => 'Format boolean',
    description => <<'_',

_
    args => {
        %common_args,
        style => {
            schema=>[str => in=>[keys %styles], default=>'one_zero'],
            description => "Available styles:\n\n".
                join("", map {" * $_" . ($styles{$_}[2] ? " ($styles{$_}[2])":"").": $styles{$_}[1] $styles{$_}[0]\n"} sort keys %styles),
            cmdline_aliases => { s=>{} },
        },
        true_char => {
            summary => 'Instead of style, you can also specify character for true value',
            schema=>['str*'],
            cmdline_aliases => { t => {} },
        },
        false_char => {
            summary => 'Instead of style, you can also specify character for true value',
            schema=>['str*'],
            cmdline_aliases => { f => {} },
        },
        notion => {
            summary => 'What notion to use to determine true/false',
            schema => [str => in=>[qw/perl n1/], default => 'perl'],
            description => <<'_',

`perl` uses Perl notion.

`n1` (for lack of better name) is just like Perl notion, but empty array and
empty hash is considered false.

TODO: add Ruby, Python, PHP, JavaScript, etc notion.

_
        },
        # XXX: flag to ignore references
    },
    tags => [qw/datatype:bool itemfunc formatting/],
};
sub bool {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    _bool_begin(\%args);
    while (my ($index, $item) = each @$in) {
        push @$out, _bool_item($item, \%args);
    }

    [200, "OK"];
}

sub _bool_begin {
    my $args = shift;

    $args->{notion} //= 'perl';
    $args->{style}  //= 'one_zero';
    $args->{style} = 'one_zero' if !$styles{$args->{style}};

    $args->{true_char}  //= $styles{$args->{style}}[0];
    $args->{false_char} //= $styles{$args->{style}}[1];
}

sub _bool_item {
    my ($item, $args) = @_;

    my $t = _is_true($item, $args->{notion});
    $t ? $args->{true_char} : defined($t) ? $args->{false_char} : undef;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl([bool => {style=>"check_cross"}], [0, "one", 2, ""])
 # => ("✕","✓","✓","✕")

In command line:

 % echo -e "0\none\n2\n\n" | dux bool -s y_n --format=text-simple
 n
 y
 y
 n

=cut
