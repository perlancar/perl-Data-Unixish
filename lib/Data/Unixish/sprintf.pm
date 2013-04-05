package Data::Unixish::sprintf;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';

use Scalar::Util 'looks_like_number';

# VERSION

our %SPEC;

$SPEC{sprintf} = {
    v => 1.1,
    summary => 'Apply sprintf() on input',
    description => <<'_',

Array will also be processed (all the elements are fed to sprintf(), the result
is a single string), unless `skip_array` is set to true.

Non-numbers can be skipped if you use `skip_non_number`.

Undef, hashes, and other non-scalars are ignored.

_
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
        format => {
            schema=>['str*'],
            cmdline_aliases => { f=>{} },
            req => 1,
            pos => 0,
        },
        skip_non_number => {
            schema=>[bool => default=>0],
        },
        skip_array => {
            schema=>[bool => default=>0],
        },
    },
    tags => [qw/format/],
};
sub sprintf {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $format = $args{format};

    while (my ($index, $item) = each @$in) {
        {
            last unless defined($item);
            my $r = ref($item);
            if ($r eq 'ARRAY' && !$args{skip_array}) {
                $item = CORE::sprintf($format, @$item);
                last;
            }
            last if $r;
            last if $item eq '';
            last if !looks_like_number($item) && $args{skip_non_number};
            {
                no warnings;
                $item = CORE::sprintf($format, $item);
            }
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Apply sprintf() on input

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::sprintf;
 my $in  = [0, 1, [2], {}, "", undef];
 my $out = [];
 Data::Unixish::sprintf(in=>$in, out=>$out, format=>"%.1f");
 # $out = ["0.0", "1.0", "2.0", {}, "", undef];

In command line:

 % echo -e "0\n1\n\nx\n" | dux sprintf -f "%.1f" --skip-non-number --format=text-simple
 0.0
 1.0

 x

=cut

