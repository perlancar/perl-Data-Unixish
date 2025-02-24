package Data::Unixish::rins;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

$SPEC{rins} = {
    v => 1.1,
    summary => 'Add some text at the end of each line of text',
    description => <<'MARKDOWN',

This is sort of a counterpart for rtrim, which removes whitespace at the end
(right) of each line of text.

MARKDOWN
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
sub rins {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        push @$out, _rins_item($item, \%args);
    }

    [200, "OK"];
}

sub _rins_item {
    my ($item, $args) = @_;
    if (defined($item) && !ref($item)) {
        $item =~ s/$/$args->{text}/mg;
    }
    return $item;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(aduxa);
 my @res = aduxa([rins => {text=>"xx"}, "a", "b ", "c\nd ", undef, ["e"]);
 # => ("axx", "b xx", "cxx\nd xx", undef, ["e"])

In command line:

 % echo -e "1\n2 " | dux rins --text xx
 1xx
 2 xx


=head1 SEE ALSO

lins, indent

=cut
