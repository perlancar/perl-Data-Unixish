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
            cmdline_aliases => { f=>{} },
        },
        start => {
            summary => 'Number to start from',
            schema  => [int => default => 1],
            cmdline_aliases => { s=>{} },
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
    tags => [qw/text itemfunc/],
    "x.dux.strip_newlines" => 0, # for duxapp < 1.41, will be removed later
    "x.app.dux.strip_newlines" => 0,
};
sub linum {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    _linum_begin(\%args);
    while (my ($index, $item) = each @$in) {
        push @$out, _linum_item($item, \%args);
    }

    [200, "OK"];
}

sub _linum_begin {
    my $args = shift;

    $args->{format} //= '%4s|';
    $args->{blank_empty_lines} //= 1;
    $args->{start} //= 1;

    # abuse, use args to store a temp var
    $args->{_lineno} = $args->{start};
}

sub _linum_item {
    my ($item, $args) = @_;

    if (defined($item) && !ref($item)) {
        my @l;
        for (split /^/, $item) {
            my $n;
            $n = ($args->{blank_empty_lines} && !/\S/) ? "" : $args->{_lineno};
            push @l, sprintf($args->{format}, $n), $_;
            $args->{_lineno}++;
        }
        $item = join "", @l;
        chomp($item) if $args->{-dux_cli};
    }
    return $item;
}

1;
# ABSTRACT: 

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
