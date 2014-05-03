package Data::Unixish::sprintf;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
use POSIX qw(locale_h);
use Scalar::Util 'looks_like_number';

# VERSION

our %SPEC;

$SPEC{sprintf} = {
    v => 1.1,
    summary => 'Apply sprintf() on input',
    description => <<'_',

Array will also be processed (all the elements are fed to sprintf(), the result
is a single string), unless `skip_array` is set to true.

Non-numbers can be skipped if you use `skip_non_number`.

Undef, hashes, and other non-scalars are ignored.

_
    args => {
        %common_args,
        format => {
            schema=>['str*'],
            cmdline_aliases => { f=>{} },
            req => 1,
            pos => 0,
        },
        skip_non_number => {
            schema=>[bool => default=>0],
        },
        skip_array => {
            schema=>[bool => default=>0],
        },
    },
    tags => [qw/formatting itemfunc text/],
};
sub sprintf {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $format = $args{format};

    my $orig_locale = _sprintf_begin();

    while (my ($index, $item) = each @$in) {
        push @$out, _sprintf_item($item, \%args);
    }

    _sprintf_end(\%args, $orig_locale);

    [200, "OK"];
}

sub _sprintf_begin {
    my $orig_locale = setlocale(LC_ALL);
    if ($ENV{LC_NUMERIC}) {
        setlocale(LC_NUMERIC, $ENV{LC_NUMERIC});
    } elsif ($ENV{LC_ALL}) {
        setlocale(LC_ALL, $ENV{LC_ALL});
    } elsif ($ENV{LANG}) {
        setlocale(LC_ALL, $ENV{LANG});
    }
    return $orig_locale;
}

sub _sprintf_end {
    my ($args, $orig_locale) = @_;
    setlocale(LC_ALL, $orig_locale);
}

sub _sprintf_item {
    my ($item, $args) = @_;

    {
        last unless defined($item);

        my $r = ref($item);
        if ($r eq 'ARRAY' && !$args->{skip_array}) {
            no warnings;
            $item = CORE::sprintf($args->{format}, @$item);
            last;
        }
        last if $r;
        last if $item eq '';
        last if !looks_like_number($item) && $args->{skip_non_number};
        {
            no warnings;
            $item = CORE::sprintf($args->{format}, $item);
        }
    }
    return $item;
}

1;
# ABSTRACT: Apply sprintf() on input

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl([sprintf => {format=>"%.1f"}], 0, 1, [2], {}, "", undef);
 # => ("0.0", "1.0", "2.0", {}, "", undef)

In command line:

 % echo -e "0\n1\n\nx\n" | dux sprintf -f "%.1f" --skip-non-number --format=text-simple
 0.0
 1.0

 x


=head1 SEE ALSO

printf(1)

L<Data::Unixish::sprintfn>

=cut
