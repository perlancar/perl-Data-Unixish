package Data::Unixish::ucfirst;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{ucfirst} = {
    v => 1.1,
    summary => 'Convert first character of text to uppercase',
    description => <<'_',

_
    args => {
        %common_args,
    },
    tags => [qw/text/],
};
sub ucfirst {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        if (defined($item) && !ref($item)) {
            $item = CORE::ucfirst($item);
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Convert first character of text to uppercase

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl('ucfirst', 'steven', 'de Java'); # => ('Steven', 'De Java')

In command line:

 % echo -e "steven" | dux ucfirst
 Steven

=cut
