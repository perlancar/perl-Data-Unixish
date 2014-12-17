package Data::Unixish::rand;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
# VERSION

our %SPEC;

$SPEC{rand} = {
    v => 1.1,
    summary => 'Generate a stream of random numbers',
    args => {
        %common_args,
        min => {
            summary => 'Minimum possible value (inclusive)',
            schema => ['float*', default=>0],
            cmdline_aliases => { a=>{} },
        },
        max => {
            summary => 'Maximum possible value (inclusive)',
            schema => ['float*', default=>1],
            cmdline_aliases => { b=>{} },
        },
        int => {
            schema => ['bool*', default=>0],
            cmdline_aliases => { i=>{} },
        },
        num => {
            summary => 'Number of numbers to generate, -1 means infinite',
            schema => ['int*', default=>1],
            cmdline_aliases => { n=>{} },
        },
    },
    tags => [qw/datatype:num gen-data/],
    "x.dux.is_stream_output" => 1, # for duxapp < 1.41, will be removed later
    'x.app.dux.is_stream_output' => 1,
};
sub rand {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    # XXX schema
    my $min = $args{min} // 0;
    my $max = $args{max} // 1;
    my $int = $args{int};
    my $num = $args{num} // 1;

    my $i = 0;
    while (1) {
        last if $num >= 0 && ++$i > $num;
        my $rand = $min + rand()*($max-$min);
        $rand = sprintf("%.0f", $rand) if $int;
        push @$out, $rand;
    }

    [200, "OK"];
}

1;
# ABSTRACT: 

=head1 SYNOPSIS

In command line:

 % dux rand
 0.0744685671097649

 % dux rand --min 1 --max 10 --num 5 --int
 3
 4
 1
 1
 5


=head1 SEE ALSO

=cut
