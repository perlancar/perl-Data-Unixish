package Data::Unixish::head;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';

# VERSION

our %SPEC;

$SPEC{head} = {
    v => 1.1,
    summary => 'Output the first items of data',
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
        items => {
            summary => 'Number of items to output',
            schema=>['int*' => {default=>10}],
            tags => ['main'],
            cmdline_aliases => { n=>{} },
        },
    },
    tags => [qw/filtering/],
};
sub head {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $n = $args{items} // 10;

    while (my ($index, $item) = each @$in) {
        last if $index >= $n;
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Output the first items of data

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::head;
 my @res;
 @res = dux("head", 1..100); # => (1..10)
 @res = dux([head => {items=>3}], 1..100); # => (1, 2, 3)

In command line:

 % seq 1 100 | dux head -n 20 | dux tail --format=text-simple -n 5
 16
 17
 18
 19
 20

=cut
