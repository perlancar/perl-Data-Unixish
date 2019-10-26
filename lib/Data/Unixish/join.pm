package Data::Unixish::join;

# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

our %SPEC;

$SPEC{join} = {
    v => 1.1,
    summary => 'Join elements of array into string',
    description => <<'_',

_
    args => {
        %common_args,
        string => {
            summary => 'String to join elements with',
            schema  => 'str*',
            default => '',
            pos     => 0,
        },
    },
    tags => [qw/text datatype-in:array itemfunc/],
};
sub join {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        push @$out, ref $item eq 'ARRAY' ? CORE::join($args{string}//'', @$item) : $item;
    }

    [200, "OK"];
}

sub _join_item {
    my ($item, $args) = @_;

    ref $item eq 'ARRAY' ? CORE::join($args->{string}//'', @$item) : $item;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 @res = lduxl([join => {string=>', '}], ["a","b","c"], ["d","e"], "f,g");
 # => ("a, b, c", "d, e", "f,g")


=head1 SEE ALSO

L<Data::Unixish::split>

L<Data::Unixish::splice>

=cut
