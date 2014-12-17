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
    tags => [qw/text itemfunc/],
};
sub uc {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        push @$out, _uc_item($item);
    }

    [200, "OK"];
}

sub _uc_item {
    my $item = shift;

    if (defined($item) && !ref($item)) {
        return CORE::uc($item);
    } else {
        return $item;
    }
}

1;
# ABSTRACT: 

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl('uc', 'januar', 'Januar'); # => ('JANUAR', 'JANUAR')

In command line:

 % echo -e "januar" | dux uc
 JANUAR

=cut
