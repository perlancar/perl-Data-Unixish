package Data::Unixish::split;

use 5.010001;
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

sub _pattern_to_re {
    my $args = shift;

    my $re;
    my $pattern = $args->{pattern}; defined $pattern or die "Please specify pattern";
    if ($args->{fixed_string}) {
        $re = $args->{ignore_case} ? qr/\Q$pattern/i : qr/\Q$pattern/;
    } else {
        eval { $re = $args->{ignore_case} ? qr/$pattern/i : qr/$pattern/ };
        die "Invalid pattern: $@" if $@;
    }

    $re;
}

$SPEC{split} = {
    v => 1.1,
    summary => 'Split string into array',
    description => <<'MARKDOWN',

MARKDOWN
    args => {
        %common_args,
        pattern => {
            summary => 'Pattern or string',
            schema  => 'str*',
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
        limit => {
            schema  => 'uint*',
            default => 0,
            pos     => 1,
        },
    },
    tags => [qw/text itemfunc/],
};
sub split {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    # we don't call _split_item() to optimize
    my $re = _pattern_to_re(\%args);
    while (my ($index, $item) = each @$in) {
        push @$out, [CORE::split($re, $item, $args{limit}//0)];
    }

    [200, "OK"];
}

sub _split_item {
    my ($item, $args) = @_;

    my $re = _pattern_to_re($args);
    [CORE::split($re, $item, $args->{limit}//0)];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 @res = lduxl([split => {pattern=>','}], "a,b,c", "d,e");
 # => (["a","b","c"], ["d","e"])


=head1 SEE ALSO

Perl's C<split> in L<perlfunc>

L<Data::Unixish::join>

L<Data::Unixish::splice>

=cut
