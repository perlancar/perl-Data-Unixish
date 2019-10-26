package Data::Unixish::sort;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

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
        %common_args,
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
        random => {
            summary => 'Whether to sort by random',
            schema=>[bool => {default=>0}],
            cmdline_aliases => { R=>{} },
        },

        key_element => {
            summary => 'Sort using an array element',
            schema => 'uint*',
            description => <<'_',

If specified, `sort` will assume the item is an array and will sort using the
<key_element>'th element (zero-based) as key. If an item turns out to not be an
array, the item itself is used as key.

_
        },
    },
    tags => [qw/ordering/],
};
sub sort {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $numeric = $args{numeric};
    my $reverse = $args{reverse} ? -1 : 1;
    my $ci      = $args{ci};
    my $random  = $args{random};

    no warnings;
    my @buf;

    # special case
    if ($random) {
        require List::Util;
        while (my ($index, $item) = each @$in) {
            push @buf, $item;
        }
        push @$out, $_ for (List::Util::shuffle(@buf));
        return [200, "OK"];
    }

    while (my ($index, $item) = each @$in) {
        my $key;
        if (defined $args{key_element}) {
            $key = ref $item eq 'ARRAY' ? ($item->[$args{key_element}] // '') : $item;
        } else {
            $key = $item;
        }
        $key = lc($key) if $ci;
        # XXX: optimize: when !ci && !key_element, just use $item as $key so no
        # need to produce a separate $key
        push @buf, [$item, $key, $numeric ? $key+0 : undef];
    }

    my $sortsub;
    if ($numeric) {
        $sortsub = sub { $reverse * (
            ($a->[2] <=> $b->[2]) || ($a->[1] cmp $b->[1]) ) };
    } else {
        $sortsub = sub { $reverse * (
            ($a->[1] cmp $b->[1]) ) };
    }
    @buf = sort $sortsub @buf;

    push @$out, $_->[0] for @buf;

    [200, "OK"];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res;
 @res = lduxl('sort', 4, 7, 2, 5); # => (2, 4, 5, 7)
 @res = lduxl([sort => {reverse=>1}], 4, 7, 2, 5); # => (7, 5, 4, 2)

In command line:

 % echo -e "b\na\nc" | dux sort --format=text-simple
 a
 b
 c


=head1 SEE ALSO

sort(1)

=cut
