package Data::Unixish::yes;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
# VERSION

our %SPEC;

$SPEC{yes} = {
    v => 1.1,
    summary => 'Output a string repeatedly until killed',
    description => <<'_',

This is like the Unix <prog:yes> utility.

_
    args => {
        %common_args,
        string => {
            schema => ['str*', default=>'y'],
            pos    => 0,
            greedy => 1,
        },
    },
    tags => [qw/text gen-data/],
    'x.dux.is_stream_output' => 1, # for duxapp < 1.41, will be removed later
    'x.app.dux.is_stream_output' => 1,
};
sub yes {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    my $str = $args{string} // 'y';

    while (1) {
        push @$out, $str;
    }

    [200, "OK"];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In command line:

 % dux yes
 y
 y
 y
 ...


=head1 SEE ALSO

yes(1)

=cut
