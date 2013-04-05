package Data::Unixish::sprintfn;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';

use Scalar::Util 'looks_like_number';
use Text::sprintfn ();

# VERSION

our %SPEC;

$SPEC{sprintfn} = {
    v => 1.1,
    summary => 'Like sprintf, but use sprintfn() from Text::sprintfn',
    description => <<'_',

Unlike in *sprintf*, with this function, hash will also be processed.

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
        skip_hash => {
            schema=>[bool => default=>0],
        },
    },
    tags => [qw/format/],
};
sub sprintfn {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $format = $args{format};

    while (my ($index, $item) = each @$in) {
        {
            last unless defined($item);
            my $r = ref($item);
            if ($r eq 'ARRAY' && !$args{skip_array}) {
                no warnings;
                $item = Text::sprintfn::sprintfn($format, @$item);
                last;
            }
            if ($r eq 'HASH' && !$args{skip_hash}) {
                no warnings;
                $item = Text::sprintfn::sprintfn($format, $item);
                last;
            }
            last if $r;
            last if $item eq '';
            last if !looks_like_number($item) && $args{skip_non_number};
            {
                no warnings;
                $item = Text::sprintfn::sprintfn($format, $item);
            }
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Like sprintf, but use sprintfn() from Text::sprintfn

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::sprintfn;
 my $in  = [{n=>1}, {n=>2}, "", undef];
 my $out = [];
 Data::Unixish::sprintfn::sprintfn(in=>$in, out=>$out, format=>"%(n).1f");
 # $out = ["1.0", "2.0", "", undef];

=cut

