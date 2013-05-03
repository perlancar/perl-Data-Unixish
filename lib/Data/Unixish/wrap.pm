package Data::Unixish::wrap;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
use Text::ANSI::Util qw(ta_wrap ta_mbwrap);
use Text::WideChar::Util qw(mbwrap);

# VERSION

our %SPEC;

$SPEC{wrap} = {
    v => 1.1,
    summary => 'Wrap text',
    args => {
        %common_args,
        width => {
            summary => 'Target column width',
            schema =>[int => {default=>80, min=>1}],
            cmdline_aliases => { c=>{} },
        },
        ansi => {
            summary => 'Whether to handle ANSI escape codes',
            schema => ['bool', default => 0],
        },
        mb => {
            summary => 'Whether to handle wide characters',
            schema => ['bool', default => 0],
        },
    },
    tags => [qw/text/],
};
sub wrap {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $w     = $args{width} // 80;
    my $ansi  = $args{ansi};
    my $mb    = $args{mb};

    while (my ($index, $item) = each @$in) {
        {
            last if !defined($item) || ref($item);
            if ($ansi) {
                if ($mb) {
                    $item = ta_mbwrap($item, $w);
                } else {
                    $item = ta_wrap  ($item, $w);
                }
            } elsif ($mb) {
                $item = mbwrap($item, $w);
            } else {
                $item = Text::WideChar::Util::wrap($item, $w);
            }
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Wrap text

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 $wrapped = dux([wrap => {width=>20}], "xxxx xxxx xxxx xxxx xxxx"); # "xxxx xxxx xxxx xxxx\nxxxx"

In command line:

 % echo -e "xxxx xxxx xxxx xxxx xxxx" | dux wrap -c 20
 xxxx xxxx xxxx xxxx
 xxxx

=cut

