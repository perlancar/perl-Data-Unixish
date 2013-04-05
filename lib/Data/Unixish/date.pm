package Data::Unixish::date;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';
use POSIX qw(strftime);
use Scalar::Util qw(looks_like_number blessed);

# VERSION

our %SPEC;

$SPEC{date} = {
    v => 1.1,
    summary => 'Format date',
    description => <<'_',

_
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
        format => {
            summary => 'Format',
            schema=>[str => {default=>0}],
            cmdline_aliases => { f=>{} },
        },
        # tz?
    },
    tags => [qw/format/],
};
sub date {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $format  = $args{format} // '%Y-%m-%d %H:%M:%S';

    while (my ($index, $item) = each @$in) {
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

        $item = strftime $format, @lt;

      OUT_ITEM:
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Format date

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::date;
 my $in  = [DateTime->new(year=>2012, month=>9, day=>6), 1290380232, "foo"];
 my $out = [];
 Data::Unixish::date::date(in=>$in, out=>$out, format=>"%Y-%m-%d");
 # $out = ["2012-09-06","2010-11-22","foo"]

In command line:

 % echo -e "1290380232\nfoo" | dux date --format=text-simple
 2010-11-22 05:57:12
 foo

=cut

