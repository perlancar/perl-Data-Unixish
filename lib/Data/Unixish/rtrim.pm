package Data::Unixish::rtrim;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

# VERSION

our %SPEC;

$SPEC{rtrim} = {
    v => 1.1,
    summary => 'Strip whitespace at the end of each line of text',
    description => <<'_',

_
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
        strip_newline => {
            summary => 'Whether to strip newlines at the end of text',
            schema =>[bool => {default=>0}],
            cmdline_aliases => { nl=>{} },
        },
    },
    tags => [qw/text/],
};
sub rtrim {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $nl  = $args{nl} // 0;

    while (my ($index, $item) = each @$in) {
        my @lt;
        if (defined($item) && !ref($item)) {
            $item =~ s/[\r\n]+\z// if $nl;
            $item =~ s/[ \t]+$//mg;
        }

        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Strip whitespace at the end of each line of text

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 my @res = dux('rtrim', "x", "a   ", "b \nc  \n", undef, ["d "]);
 # => ("x", "a", "b\nc\n", undef, ["d "])

In command line:

 % echo -e "x\na  " | dux rtrim
 x
 a

=cut

