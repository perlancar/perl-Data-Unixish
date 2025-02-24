package Data::Unixish::_pad;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use String::Pad qw(pad);
use Text::ANSI::Util qw(ta_pad);
use Text::ANSI::WideUtil qw(ta_mbpad);
use Text::WideChar::Util qw(mbpad);

# AUTHORITY
# DATE
# DIST
# VERSION

sub _pad {
    my ($which, %args) = @_;
    my ($in, $out) = ($args{in}, $args{out});

    __pad_begin($which, \%args);
    while (my ($index, $item) = each @$in) {
        push @$out, __pad_item($which, $item, \%args);
    }

    [200, "OK"];
}

sub __pad_begin {
    my ($which, $args) = @_;
    $args->{char} //= ' ';
}

sub __pad_item {
    my ($which, $item, $args) = @_;

    {
        last if !defined($item) || ref($item);
        if ($args->{ansi}) {
            if ($args->{mb}) {
                $item = ta_mbpad($item, $args->{width}, $which,
                                 $args->{char}, $args->{trunc});
            } else {
                $item = ta_pad  ($item, $args->{width}, $which,
                                 $args->{char}, $args->{trunc});
            }
        } elsif ($args->{mb}) {
            $item = mbpad($item, $args->{width}, $which,
                          $args->{char}, $args->{trunc});
        } else {
            $item = pad  ($item, $args->{width}, $which,
                          $args->{char}, $args->{trunc});
        }
    }
    return $item;
}

1;
# ABSTRACT: _pad
