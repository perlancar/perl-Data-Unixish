package Data::Unixish::tail;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';

# VERSION

our %SPEC;

$SPEC{tail} = {
    v => 1.1,
    summary => 'Output the last items of data',
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
sub tail {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $n = $args{items} // 10;

    # maintain temporary buffer first
    my @buf;

    while (my ($index, $item) = each @$in) {
        push @buf, $item;
        shift @buf if @buf > $n;
    }

    # push buffer to out
    push @$out, $_ for @buf;

    [200, "OK"];
}

1;
# ABSTRACT: Output the last items of data

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::tail;
 my $in  = [1..100];
 my $out = [];
 Data::Unixish::tail::tail(in=>$in, out=>$out); # $out = [91..100]

In command line:

 % seq 1 100 | dux tail --format=text-simple -n 5
 96
 97
 98
 99
 100

=cut
