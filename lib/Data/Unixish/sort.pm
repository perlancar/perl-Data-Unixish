package Data::Unixish::sort;

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

# VERSION

our %SPEC;

$SPEC{sort} = {
    v => 1.1,
    summary => 'Sort items',
    description => <<'_',

By default sort ascibetically, unless `numeric` is set to true to sort
numerically.

_
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
        numeric => {
            summary => 'Whether to sort numerically',
            schema=>[bool => {default=>0}],
            cmdline_aliases => { n=>{} },
        },
        reverse => {
            summary => 'Whether to reverse sort result',
            schema=>[bool => {default=>0}],
            cmdline_aliases => { r=>{} },
        },
        ci => {
            summary => 'Whether to ignore case',
            schema=>[bool => {default=>0}],
            cmdline_aliases => { i=>{} },
        },
    },
    tags => [qw/sorting/],
};
sub sort {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $numeric = $args{numeric};
    my $reverse = $args{reverse} ? -1 : 1;
    my $ci      = $args{ci};

    no warnings;
    my @buf;
    while (my ($index, $item) = each @$in) {
        my $rec = [$item];
        push @$rec, $ci ? lc($item) : undef; # cache lowcased item
        push @$rec, $numeric ? $item+0 : undef; # cache numeric item
        push @buf, $rec;
    }

    my $sortsub;
    if ($numeric) {
        $sortsub = sub { $reverse * (
            ($a->[2] <=> $b->[2]) ||
                ($ci ? ($a->[1] cmp $b->[1]) : ($a->[0] cmp $b->[0]))) };
    } else {
        $sortsub = sub { $reverse * (
            $ci ? ($a->[1] cmp $b->[1]) : ($a->[0] cmp $b->[0])) };
    }
    @buf = sort $sortsub @buf;

    push @$out, $_->[0] for @buf;

    [200, "OK", $out];
}

1;
# ABSTRACT: Sort items
