package Data::Unixish::rev;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';

# VERSION

our %SPEC;

$SPEC{rev} = {
    v => 1.1,
    summary => 'Reverse items',
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
    },
    tags => [qw/ordering/],
};
sub rev {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    my @tmp;
    while (my ($index, $item) = each @$in) {
        push @tmp, $item;
    }

    push @$out, pop @tmp while @tmp;
    [200, "OK"];
}

1;
# ABSTRACT: Reverse items

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 my @rev = dux('rev', 1, 2, 3); # => (3, 2, 1)

In command line:

 % echo -e "1\n2\n3" | dux rev --format=text-simple
 3
 2
 1

=cut

