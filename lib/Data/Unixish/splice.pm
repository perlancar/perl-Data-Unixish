package Data::Unixish::splice;

use 5.010001;
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

$SPEC{splice} = {
    v => 1.1,
    summary => 'Perform Perl splice() on array',
    description => <<'MARKDOWN',

MARKDOWN
    args => {
        %common_args,
        offset => {
            schema  => 'uint*',
            req     => 1,
            pos     => 0,
        },
        length => {
            schema  => 'uint*',
            pos => 1,
        },
        list => {
            schema  => ['array*', of=>'str*'], # actually it does not have to be array of str, we just want ease of specifying on the cmdline for now
            pos => 2,
            slurpy => 1,
        },
    },
    tags => [qw/datatype-in:array itemfunc/],
};
sub splice {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        my @ary = ref $item eq 'ARRAY' ? @$item : ($item);
        if (defined $args{list}) {
            CORE::splice(@ary, $args{offset}, $args{length}, @{ $args{list} });
        } elsif (defined $args{length}) {
            CORE::splice(@ary, $args{offset}, $args{length});
        } else {
            CORE::splice(@ary, $args{offset});
        }
        push @$out, \@ary;
    }

    [200, "OK"];
}

sub _splice_item {
    my ($item, $args) = @_;

    my @ary = ref $item eq 'ARRAY' ? @$item : ($item);
    if (defined $args->{list}) {
        CORE::splice(@ary, $args->{offset}, $args->{length}, @{ $args->{list} });
    } elsif (defined $args->{length}) {
        CORE::splice(@ary, $args->{offset}, $args->{length});
    } else {
        CORE::splice(@ary, $args->{offset});
    }
    \@ary;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 @res = lduxl([splice => {offset=>1}], ["a","b","c"], ["d","e"],"f,g");
 # => (["a"], ["d"], [])


=head1 SEE ALSO

Perl's C<splice> in L<perlfunc>

L<Data::Unixish::split>

L<Data::Unixish::join>

=cut
