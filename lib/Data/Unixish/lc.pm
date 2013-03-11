package Data::Unixish::lc;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

# VERSION

our %SPEC;

$SPEC{lc} = {
    v => 1.1,
    summary => 'Convert text to lowercase',
    description => <<'_',

_
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
    },
    tags => [qw/text/],
};
sub lc {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        if (defined($item) && !ref($item)) {
            $item = CORE::lc($item);
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Convert text to lowercase

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::lc;
 my $in  = ["STEVEN"];
 my $out = [];
 Data::Unixish::lc::lc(in=>$in, out=>$out);
 # $out = ["steven"]

In command line:

 % echo -e "STEVEN" | dux lc
 steven

=cut

