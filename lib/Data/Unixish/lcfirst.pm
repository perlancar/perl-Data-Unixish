package Data::Unixish::lcfirst;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{lcfirst} = {
    v => 1.1,
    summary => 'Convert first character of text to lowercase',
    description => <<'_',

_
    args => {
        %common_args,
    },
    tags => [qw/text/],
};
sub lcfirst {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        if (defined($item) && !ref($item)) {
            $item = CORE::lcfirst($item);
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Convert first character of text to lowercase

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl('lcfirst', 'Steven', 'STEVEN'); # => ('steven', 'sTEVEN')

In command line:

 % echo -e "STEVEN" | dux lcfirst
 sTEVEN

=cut
