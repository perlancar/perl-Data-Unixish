package Data::Unixish::wrap;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Text::Wrap ();

# VERSION

our %SPEC;

$SPEC{wrap} = {
    v => 1.1,
    summary => 'Wrap text',
    description => <<'_',

Currently implemented using Text::Wrap standard Perl module.

_
    args => {
        in  => {schema=>'any'},
        out => {schema=>'any'},
        columns => {
            summary => 'Target column width',
            schema =>[int => {default=>80, min=>1}],
            cmdline_aliases => { c=>{} },
        },
    },
    tags => [qw/text/],
};
sub wrap {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $cols = $args{columns} // 80;

    local $Text::Wrap::columns = $cols;

    while (my ($index, $item) = each @$in) {
        my @lt;
        if (defined($item) && !ref($item)) {
            $item = Text::Wrap::wrap("", "", $item);
        }

        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Wrap text

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::wrap;
 my $in  = ["xxxx xxxx xxxx xxxx xxxx"];
 my $out = [];
 Data::Unixish::wrap::wrap(in=>$in, out=>$out, columns => 20);
 # $out = ["xxxx xxxx xxxx xxxx\nxxxx"]

In command line:

 % echo -e "xxxx xxxx xxxx xxxx xxxx" | dux rtrim -c 20
 xxxx xxxx xxxx xxxx
 xxxx

=cut

