package Data::Unixish::sum;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';
use Scalar::Util 'looks_like_number';

# VERSION

our %SPEC;

$SPEC{sum} = {
    v => 1.1,
    summary => 'Sum numbers',
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
    },
    tags => [qw/group/],
};
sub sum {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    my $sum = 0;
    while (my ($index, $item) = each @$in) {
        $sum += $item if looks_like_number($item);
    }

    push @$out, $sum;
    [200, "OK"];
}

1;
# ABSTRACT: Sum numbers

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::sum;
 my $in  = [1, 2, 3];
 my $out = [];
 Data::Unixish::sum::sum(in=>$in, out=>$out); # $out = [6]

In command line:

 % seq 1 100 | dux sum
 .------.
 | 5050 |
 '------'

=cut
