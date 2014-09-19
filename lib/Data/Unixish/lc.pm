package Data::Unixish::lc;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{lc} = {
    v => 1.1,
    summary => 'Convert text to lowercase',
    description => <<'_',

_
    args => {
        %common_args,
    },
    tags => [qw/text itemfunc/],
};
sub lc {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        push @$out, _lc_item($item);
    }

    [200, "OK"];
}

sub _lc_item {
    my $item = shift;
    if (defined($item) && !ref($item)) {
        $item = CORE::lc($item);
    }
    return $item;
}

1;
# ABSTRACT: Convert text to lowercase

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl('lc', 'Januar', 'JANUAR'); # => ('januar', 'januar')

In command line:

 % echo -e "JANUAR" | dux lc
 januar

=cut
