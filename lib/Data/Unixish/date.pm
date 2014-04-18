package Data::Unixish::date;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';
use POSIX qw(strftime);
use Scalar::Util qw(looks_like_number blessed);

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{date} = {
    v => 1.1,
    summary => 'Format date',
    description => <<'_',

_
    args => {
        %common_args,
        format => {
            summary => 'Format',
            schema=>[str => {default=>0}],
            cmdline_aliases => { f=>{} },
        },
        # tz?
    },
    tags => [qw/format itemfunc/],
};
sub date {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    _date_begin(\%args);
    while (my ($index, $item) = each @$in) {
        push @$out, _date_item($item, \%args);
    }

    [200, "OK"];
}

sub _date_begin {
    my $args = shift;

    $args->{format} //= '%Y-%m-%d %H:%M:%S';
}

sub _date_item {
    my ($item, $args) = @_;

    my @lt;
    if (looks_like_number($item) &&
            $item >= 0 && $item <= 2**31) { # XXX Y2038-bug
        @lt = localtime($item);
    } elsif (blessed($item) && $item->isa('DateTime')) {
        # XXX timezone!
        @lt = localtime($item->epoch);
    } else {
        goto OUT_ITEM;
    }

    $item = strftime $args->{format}, @lt;

  OUT_ITEM:
    return $item;
}

1;
# ABSTRACT: Format date

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl([date => {format=>"%Y-%m-%d"}], DateTime->new(year=>2012, month=>9, day=>6), 1290380232, "foo");
 # => ("2012-09-06","2010-11-22","foo")

In command line:

 % echo -e "1290380232\nfoo" | dux date --format=text-simple
 2010-11-22 05:57:12
 foo

=cut
