package Data::Unixish::sprintfn;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
use POSIX qw(locale_h);
use Scalar::Util 'looks_like_number';
use Text::sprintfn ();

# VERSION

our %SPEC;

$SPEC{sprintfn} = {
    v => 1.1,
    summary => 'Like sprintf, but use sprintfn() from Text::sprintfn',
    description => <<'_',

Unlike in *sprintf*, with this function, hash will also be processed.

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
        skip_hash => {
            schema=>[bool => default=>0],
        },
    },
    tags => [qw/formatting itemfunc text/],
};
sub sprintfn {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    my $orig_locale = _sprintfn_begin(\%args);
    while (my ($index, $item) = each @$in) {
        push @$out, _sprintfn_item($item, \%args);
    }
    _sprintfn_end(\%args, $orig_locale);

    [200, "OK"];
}

sub _sprintfn_begin {
    my $args = shift;

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

sub _sprintfn_item {
    my ($item, $args) = @_;

    {
        last unless defined($item);
        my $r = ref($item);
        if ($r eq 'ARRAY' && !$args->{skip_array}) {
            no warnings;
            $item = Text::sprintfn::sprintfn($args->{format}, @$item);
            last;
        }
        if ($r eq 'HASH' && !$args->{skip_hash}) {
            no warnings;
            $item = Text::sprintfn::sprintfn($args->{format}, $item);
            last;
        }
        last if $r;
        last if $item eq '';
        last if !looks_like_number($item) && $args->{skip_non_number};
        {
            no warnings;
            $item = Text::sprintfn::sprintfn($args->{format}, $item);
        }
    }
    return $item;
}

sub _sprintfn_end {
    my ($args, $orig_locale) = @_;
    setlocale(LC_ALL, $orig_locale);
}

1;
# ABSTRACT: Like sprintf, but use sprintfn() from Text::sprintfn

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl([sprintfn => {format=>"%(n).1f"}], {n=>1}, {n=>2}, "", undef);
 # => ("1.0", "2.0", "", undef)


=head1 SEE ALSO

L<Data::Unixish::sprintf>

=cut
