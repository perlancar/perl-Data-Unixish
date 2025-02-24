package Data::Unixish::trim;

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

$SPEC{trim} = {
    v => 1.1,
    summary => 'Strip whitespace at the beginning and end of each line of text',
    description => <<'MARKDOWN',

MARKDOWN
    args => {
        %common_args,
        strip_newline => {
            summary => 'Whether to strip newlines at the '.
                'beginning and end of text',
            schema =>[bool => {default=>0}],
            cmdline_aliases => { nl=>{} },
        },
    },
    tags => [qw/text itemfunc/],
};
sub trim {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        push @$out, _trim_item($item, \%args);
    }

    [200, "OK"];
}

sub _trim_item {
    my ($item, $args) = @_;

    if (defined($item) && !ref($item)) {
        $item =~ s/\A[\r\n]+// if $args->{strip_newline};
        $item =~ s/[\r\n]+\z// if $args->{strip_newline};
        $item =~ s/^[ \t]+//mg;
        $item =~ s/[ \t]+$//mg;
    }
    return $item;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 @res = lduxl('trim', "x", "   a   ", "  b  \n   c  \n", undef, [" d "]);
 # => ("x", "a", "b\nc\n", undef, [" d "])

In command line:

 % echo -e "x\n a " | dux trim
 x
 a

=cut
