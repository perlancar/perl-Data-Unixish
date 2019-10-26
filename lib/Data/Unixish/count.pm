package Data::Unixish::count;

# DATE
# DIST
# VERSION

use 5.010001;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::ger;

use Data::Unixish::Util qw(%common_args);

our %SPEC;

$SPEC{count} = {
    v => 1.1,
    summary => 'Count substrings (or regex pattern matches) in a string',
    description => <<'_',

_
    args => {
        %common_args,
        pattern => {
            summary => 'Pattern or substring',
            schema  => ['str*'],
            req     => 1,
            pos     => 0,
        },
        fixed_string => {
            summary => 'Interpret pattern as fixed string instead of regular expression',
            schema  => 'true*',
            cmdline_aliases => {F=>{}},
        },
        ignore_case => {
            summary => 'Whether to ignore case',
            schema  => 'bool*',
            cmdline_aliases => {i=>{}},
        },
    },
    tags => [qw/itemfunc text regex/],
};
sub count {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    my $re;
    my $pattern = $args{pattern}; defined $pattern or die "Please specify pattern";
    if ($args{fixed_string}) {
        $re = $args{ignore_case} ? qr/\Q$pattern/i : qr/\Q$pattern/;
    } else {
        eval { $re = $args{ignore_case} ? qr/$pattern/i : qr/$pattern/ };
        die "Invalid pattern: $@" if $@;
    }

    while (my ($index, $item) = each @$in) {
        my $n = 0;
        $n++ while $item =~ /$re/g;
        push @$out, $n;
    }

    [200, "OK"];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl([count => {pattern=>'is', fixed_string=>1}], "book", "this", "This is a book");
 # => (0, 1, 2)

In command-line:

 % echo -e "book\nthis\nThis is a book" | dux count is -F
 0
 1
 2


=head1 SEE ALSO

=cut
