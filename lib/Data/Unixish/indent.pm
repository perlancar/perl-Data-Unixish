package Data::Unixish::indent;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{indent} = {
    v => 1.1,
    summary => 'Add spaces or tabs to the beginnning of each line of text',
    args => {
        %common_args,
        num => {
            summary => 'Number of spaces to add',
            schema  => ['int*', default=>4],
            cmdline_aliases => {
                n => {},
            },
        },
        tab => {
            summary => 'Number of spaces to add',
            schema  => ['bool' => default => 0],
            cmdline_aliases => {
                t => {},
            },
        },
    },
    tags => [qw/text itemfunc/],
};
sub indent {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    _indent_begin(\%args);
    while (my ($index, $item) = each @$in) {
        push @$out, _indent_item($item, \%args);
    }

    [200, "OK"];
}

sub _indent_begin {
    my $args = shift;

    # args abused to store state
    $args->{_indent} = ($args->{tab} ? "\t" : " ") x ($args->{num} // 4);
}

sub _indent_item {
    my ($item, $args) = @_;

    if (defined($item) && !ref($item)) {
        $item =~ s/^/$args->{_indent}/mg;
    }
    return $item;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(aduxa);
 my @res = aduxa('indent', "a", " b", "", undef, ["c"]);
 # => ("    a", "     b", "    ", undef, ["c"])

In command line:

 % echo -e "1\n 2" | dux indent -n 2
   1
    2


=head1 SEE ALSO

lins, rins

=cut
