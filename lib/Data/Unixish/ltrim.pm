package Data::Unixish::ltrim;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{ltrim} = {
    v => 1.1,
    summary => 'Strip whitespace at the beginning of each line of text',
    description => <<'_',

_
    args => {
        %common_args,
        strip_newline => {
            summary => 'Whether to strip newlines at the beginning of text',
            schema =>[bool => {default=>0}],
            cmdline_aliases => { nl=>{} },
        },
    },
    tags => [qw/text/],
};
sub ltrim {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $nl  = $args{strip_newline} // 0;

    while (my ($index, $item) = each @$in) {
        my @lt;
        if (defined($item) && !ref($item)) {
            $item =~ s/\A[\r\n]+// if $nl;
            $item =~ s/^[ \t]+//mg;
        }

        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Strip whitespace at the beginning of each line of text

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 my @res = dux('ltrim', "x", "   a", "  b\n   c\n", undef, [" d"]);
 # => ("x", "a", "b\nc\n", undef, [" d"])

In command line:

 % echo -e "x\n  a" | dux ltrim
 x
 a

=cut
