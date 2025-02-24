package Data::Unixish::pick;

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

$SPEC{pick} = {
    v => 1.1,
    summary => 'Pick one or more random items',
    args => {
        %common_args,
        items => {
            summary => 'Number of items to pick',
            schema=>['int*' => {default=>1}],
            tags => ['main'],
            cmdline_aliases => { n=>{} },
            pos => 0,
        },
    },
    tags => [qw/filtering/],
};
sub pick {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $n = $args{items} // 1;

    my @picked;
    while (my ($index, $item) = each @$in) {
        if (@picked < $n) {
            # we haven't reached n items, put item to picked list, in a random
            # position
            splice @picked, rand(@picked+1), 0, $item;
        } else {
            # we have reached n items, just replace an item randomly, using
            # algorithm from Learning Perl, slightly modified.
            rand($index+1) < @picked and
                splice @picked, rand(@picked), 1, $item;
        }
    }

    push @$out, $_ for @picked;
    [200, "OK"];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @pick = lduxl([pick => {items=>2}], 1..100); # => (52, 33)

In command line:

 % seq 1 100 | dux pick -n 4
 .-------------------.
 | 18 | 22 |  2 | 24 |
 '----+----+----+----'

=cut
