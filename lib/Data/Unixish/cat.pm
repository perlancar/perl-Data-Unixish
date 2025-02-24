package Data::Unixish::cat;

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

$SPEC{cat} = {
    v => 1.1,
    summary => 'Pass input unchanged',
    args => {
        %common_args,
    },
    tags => [qw/filtering itemfunc/],
};
sub cat {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        push @$out, $item;
    }

    [200, "OK"];
}

sub _cat_item {
    $_[0];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl("cat", 1, 2, 3, 4); # => (1, 2, 3, 4)

In command line:

 % echo -e "1\n2\n3" | dux cat --format=text-simple
 1
 2
 3


=head1 SEE ALSO

cat(1)

=cut
