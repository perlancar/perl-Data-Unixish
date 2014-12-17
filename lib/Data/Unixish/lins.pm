package Data::Unixish::lins;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{lins} = {
    v => 1.1,
    summary => 'Add some text at the beginning of each line of text',
    description => <<'_',

This is sort of a counterpart for ltrim, which removes whitespace at the
beginning (left) of each line of text.

_
    args => {
        %common_args,
        text => {
            summary => 'The text to add',
            schema  => ['str*'],
            req     => 1,
            pos     => 0,
        },
    },
    tags => [qw/text itemfunc/],
};
sub lins {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        push @$out, _lins_item($item, \%args);
    }

    [200, "OK"];
}

sub _lins_item {
    my ($item, $args) = @_;

    if (defined($item) && !ref($item)) {
        $item =~ s/^/$args->{text}/mg;
    }
    return $item;
}

1;
# ABSTRACT: 

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(aduxa);
 my @res = aduxa([lins => {text=>"xx"}, "a", " b", "", undef, ["c"]);
 # => ("xxa", "xx b", "xx", undef, ["c"])

In command line:

 % echo -e "1\n 2" | dux lins --text xx
 xx1
 xx 2


=head1 SEE ALSO

indent, rins

=cut
