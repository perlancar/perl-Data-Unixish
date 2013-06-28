package Data::Unixish::map;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{map} = {
    v => 1.1,
    summary => 'Perl map',
    description => <<'_',

Process each item through a callback.

_
    args => {
        %common_args,
        callback => {
            summary => 'The callback coderef to use',
        },
    },
    tags => [qw//],
};
sub map {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $callback = $args{callback} or die "missing callback for map";

    local ($., $_);
    while (($., $_) = each @$in) {
        push @$out, $callback->();
    }

    [200, "OK"];
}

1;
# ABSTRACT: Perl map

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 my @res = dux([map => {callback => sub { 1 + $_ }}], 1, 2, 3);
 # => (2, 3, 4)

=cut
