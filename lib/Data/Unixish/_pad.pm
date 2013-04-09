package Data::Unixish::_pad;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';

use SHARYANTO::String::Util qw(pad);
use Text::ANSI::Util qw(ta_pad ta_mbpad);
use Text::WideChar::Util qw(mbpad);

# VERSION

sub _pad {
    my ($which, %args) = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $w     = $args{width};
    my $ansi  = $args{ansi};
    my $mb    = $args{mb};
    my $char  = $args{padchar} // " ";
    my $trunc = $args{trunc};

    while (my ($index, $item) = each @$in) {
        {
            last if !defined($item) || ref($item);
            if ($ansi) {
                if ($mb) {
                    $item = ta_mbpad($item, $w, $which, $char, $trunc);
                } else {
                    $item = ta_pad  ($item, $w, $which, $char, $trunc);
                }
            } elsif ($mb) {
                $item = mbpad($item, $w, $which, $char, $trunc);
            } else {
                $item = pad  ($item, $w, $which, $char, $trunc);
            }
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: _pad
