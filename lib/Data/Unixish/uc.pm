package Data::Unixish::uc;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
# VERSION

our %SPEC;

$SPEC{uc} = {
    v => 1.1,
    summary => 'Convert text to uppercase',
    description => <<'_',

_
    args => {
        %common_args,
    },
    tags => [qw/text/],
};
sub uc {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        if (defined($item) && !ref($item)) {
            $item = CORE::uc($item);
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Convert text to uppercase

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl('uc', 'steven', 'Steven'); # => ('STEVEN', 'STEVEN')

In command line:

 % echo -e "steven" | dux uc
 STEVEN

=cut
