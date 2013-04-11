package Data::Unixish::shuf;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';

use List::Util qw(shuffle);

# VERSION

our %SPEC;

$SPEC{shuf} = {
    v => 1.1,
    summary => 'Shuffle items',
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
    },
    tags => [qw/ordering/],
};
sub shuf {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    my @tmp;
    while (my ($index, $item) = each @$in) {
        push @tmp, $item;
    }

    push @$out, $_ for shuffle @tmp;
    [200, "OK"];
}

1;
# ABSTRACT: Shuffle items

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 my @shuffled = dux('shuffle', 1, 2, 3); # => (2, 1, 3)

In command line:

 % echo -e "1\n2\n3" | dux shuf --format=text-simple
 3
 1
 2

=cut

