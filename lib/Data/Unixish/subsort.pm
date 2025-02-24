package Data::Unixish::subsort;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

$SPEC{subsort} = {
    v => 1.1,
    summary => 'Sort items using Sort::Sub routine',
    args => {
        %common_args,
        routine => {
            summary => 'Sort::Sub routine name',
            schema=>['str*', match=>qr/\A\w+\z/],
            req => 1,
            pos => 0,
        },
        routine_args => {
            summary => 'Pass arguments for Sort::Sub routine',
            schema=>['hash*', of=>'str*'],
            cmdline_aliases => {a=>{}},
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
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $routine = $args{routine} or return [400, "Please specify routine"];
    my $routine_args = $args{routine_args} // {};
    my $reverse = $args{reverse};
    my $ci      = $args{ci};

    no warnings;
    no strict 'refs'; ## no critic: TestingAndDebugging::ProhibitNoStrict
    my @buf;

    # special case
    while (my ($index, $item) = each @$in) {
        push @buf, $item;
    }

    require "Sort/Sub/$routine.pm"; ## no critic: Modules::RequireBarewordIncludes
    my $gen_sorter = \&{"Sort::Sub::$routine\::gen_sorter"};
    my $sorter = $gen_sorter->($reverse, $ci, $routine_args);

    @buf = sort {$sorter->($a, $b)} @buf;

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

 % echo -e 'a::\nb:\nc::::\nd:::' | dux subsort by_count -a pattern=:
 b:
 a::
 d:::
 c::::


=head1 SEE ALSO

L<subsort> (from L<App::subsort>)

sort(1)

L<psort> (from L<App::psort>)

=cut
