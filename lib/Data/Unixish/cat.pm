package Data::Unixish::cat;

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

# VERSION

our %SPEC;

$SPEC{cat} = {
    v => 1.1,
    summary => 'Pass input unchanged',
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
    },
    tags => [qw/filtering/],
};
sub cat {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Pass input unchanged
