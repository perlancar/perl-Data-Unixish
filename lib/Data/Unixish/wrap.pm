package Data::Unixish::wrap;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
use Text::ANSI::Util qw(ta_wrap);
use Text::ANSI::WideUtil qw(ta_mbwrap);
use Text::WideChar::Util qw(mbwrap);

# AUTHORITY
# DATE
# DIST
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
            pos => 0,
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
    tags => [qw/text itemfunc/],
};
sub wrap {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    _wrap_begin(\%args);
    while (my ($index, $item) = each @$in) {
        push @$out, _wrap_item($item, \%args);
    }

    [200, "OK"];
}

sub _wrap_begin {
    my $args = shift;
    $args->{width} //= 80;
}

sub _wrap_item {
    my ($item, $args) = @_;
    {
        last if !defined($item) || ref($item);
        if ($args->{ansi}) {
            if ($args->{mb}) {
                $item = ta_mbwrap($item, $args->{width});
            } else {
                $item = ta_wrap  ($item, $args->{width});
            }
        } elsif ($args->{mb}) {
            $item = mbwrap($item, $args->{width});
        } else {
            $item = Text::WideChar::Util::wrap($item, $args->{width});
        }
    }
    return $item;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 $wrapped = lduxl([wrap => {width=>20}], "xxxx xxxx xxxx xxxx xxxx"); # "xxxx xxxx xxxx xxxx\nxxxx"

In command line:

 % echo -e "xxxx xxxx xxxx xxxx xxxx" | dux wrap -c 20
 xxxx xxxx xxxx xxxx
 xxxx


=head1 SEE ALSO

fmt(1)

=cut
