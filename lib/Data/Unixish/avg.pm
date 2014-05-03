package Data::Unixish::avg;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
use Scalar::Util 'looks_like_number';

# VERSION

our %SPEC;

$SPEC{avg} = {
    v => 1.1,
    summary => 'Average numbers',
    args => {
        %common_args,
    },
    tags => [qw/datatype:num group/],
};
sub avg {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    my $sum = 0;
    my $n = 0;
    while (my ($index, $item) = each @$in) {
        $n++;
        $sum += $item if looks_like_number($item);
    }

    my $avg = $n ? $sum/$n : 0;

    push @$out, $avg;
    [200, "OK"];
}

1;
# ABSTRACT: Average numbers

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my $avg = lduxl('avg', 1, 2, 3, 4, 5); # => 3

In command line:

 % seq 0 100 | dux avg
 .----.
 | 50 |
 '----'

=cut
