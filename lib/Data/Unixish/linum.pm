package Data::Unixish::linum;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{linum} = {
    v => 1.1,
    summary => 'Add line numbers',
    args => {
        %common_args,
        format => {
            summary => 'Sprintf-style format to use',
            description => <<'_',

Example: `%04d|`.

_
            schema  => [str => default=>'%4s|'],
        },
        start => {
            summary => 'Number to start from',
            schema  => [int => default => 1],
        },
        blank_empty_lines => {
            schema => [bool => default=>1],
            description => <<'_',

Example when set to false:

    1|use Foo::Bar;
    2|
    3|sub blah {
    4|    my %args = @_;

Example when set to true:

    1|use Foo::Bar;
     |
    3|sub blah {
    4|    my %args = @_;

_
            cmdline_aliases => {
                b => {},
                B => {
                    summary => 'Equivalent to --noblank-empty-lines',
                    code => sub { $_[0]{blank_empty_lines} = 0 },
                },
            },
        },
    },
    tags => [qw/text/],
    "x.dux.strip_newlines" => 0,
};
sub linum {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    my $fmt = $args{format} // '%4s|';
    my $bel = $args{blank_empty_lines} // 1;
    my $lineno = ($args{start} // 1)+0;
    my $dux_cli = $args{-dux_cli};

    while (my ($index, $item) = each @$in) {
        if (defined($item) && !ref($item)) {
            my @l;
            for (split /^/, $item) {
                my $n;
                $n = ($bel && !/\S/) ? "" : $lineno;
                push @l, sprintf($fmt, $n), $_;
                $lineno++;
            }
            $item = join "", @l;
            chomp($item) if $dux_cli;
        }

        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Add line numbers

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(aduxa);
 my @res = aduxa('linum', "a", "b ", "c\nd ", undef, ["e"]);
 # => ("   1|a", "   2| b", "   3c|\n   4|d ", undef, ["e"])

In command line:

 % echo -e "a\nb\n \nd" | dux linum
    1|a
    2|b
     |
    4|d


=head1 SEE ALSO

lins, rins

=cut
