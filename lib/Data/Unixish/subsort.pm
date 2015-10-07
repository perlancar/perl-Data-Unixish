package Data::Unixish::subsort;

# DATE
# VERSION

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

our %SPEC;

$SPEC{subsort} = {
    v => 1.1,
    summary => 'Sort items using Sort::Sub routine',
    args => {
        %common_args,
        routine => {
            summary => 'Sort::Sub routine name',
            schema=>['str*'],
            req => 1,
            pos => 0,
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
    tags => [qw/ordering/],
};
sub subsort {
    require Sort::Sub;

    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $routine = $args{routine} or return [400, "Please specify routine"];
    my $reverse = $args{reverse};
    my $ci      = $args{ci};

    no warnings;
    no strict 'refs';
    my @buf;

    # special case
    while (my ($index, $item) = each @$in) {
        push @buf, $item;
    }

    Sort::Sub->import("$args{routine}<".
                          ($ci ? "i":"").
                          ($reverse ? "r":"").
                          ">");
    @buf = sort {&{"$routine"}} @buf;

    push @$out, $_ for @buf;

    [200, "OK"];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(subsort);
 my @res;
 @res = lduxl([subsort => {routine=>"naturally"}], "t1","t10","t2"); # => ("t1","t2","t10")

In command line:

 % echo -e "t1\nt10\nt2" | dux subsort naturally
 t1
 t2
 t10


=head1 SEE ALSO

L<subsort> (from L<App::subsort>)

sort(1)

L<psort> (from L<App::psort>)

=cut
