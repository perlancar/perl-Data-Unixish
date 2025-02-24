package Data::Unixish::ucfirst;

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

$SPEC{ucfirst} = {
    v => 1.1,
    summary => 'Convert first character of text to uppercase',
    description => <<'MARKDOWN',

MARKDOWN
    args => {
        %common_args,
    },
    tags => [qw/text itemfunc/],
};
sub ucfirst {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        push @$out, _ucfirst_item($item);
    }

    [200, "OK"];
}

sub _ucfirst_item {
    my $item = shift;
    if (defined($item) && !ref($item)) {
        $item = CORE::ucfirst($item);
    }
    return $item;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl('ucfirst', 'januar', 'de Java'); # => ('Januar', 'De Java')

In command line:

 % echo -e "januar" | dux ucfirst
 Januar

=cut
