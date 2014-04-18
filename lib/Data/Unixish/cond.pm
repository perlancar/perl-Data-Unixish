package Data::Unixish::cond;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

require Data::Unixish; # for siduxs
use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{cond} = {
    v => 1.1,
    summary => 'Apply dux function conditionally',
    description => <<'_',

This dux function takes a condition (a Perl code/expression) and one or two
other dux functions (A and B). Condition will be evaluated for each item (where
`$_` will be set to the current item). If condition evaluates to true, then A is
applied to the item, else B. All the dux functions must be itemfunc.

_
    args => {
        %common_args,
        if => {
            summary => 'Perl code that specifies the condition',
            schema  => ['any*' => of => ['str*', 'code*']],
            req     => 1,
            pos     => 0,
        },
        then => {
            summary => 'dux function to be applied if condition is true',
            schema  => ['any*' => of => ['str*', 'array*']], # XXX dux
            req     => 1,
            pos     => 1,
        },
        else => {
            summary => 'dux function to be applied if condition is false',
            schema  => ['any*' => of => ['str*', 'array*']], # XXX dux
            pos     => 2,
        },
    },
    tags => [qw/perl unsafe itemfunc/],
};
sub cond {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    _cond_begin(\%args);
    local $.;
    my $item;
    while (($., $item) = each @$in) {
        push @$out, _cond_item->($item, \%args);
    }

    [200, "OK"];
}

sub _cond_begin {
    my $args = shift;

    if (ref($args->{if}) ne 'CODE') {
        $args->{if} = eval "sub { $args->{if} }";
        die "invalid Perl code for if: $@" if $@;
    }
    $args->{then} //= 'cat';
    $args->{else} //= 'cat';
}

sub _cond_item {
    my ($item, $args) = @_;

    local $_ = $item;

    # XXX to be more efficient, skip siduxs and do it ourselves
    if ($args->{if}->()) {
        return Data::Unixish::siduxs($args->{then}, $item);
    } else {
        return Data::Unixish::siduxs($args->{else}, $item);
    }
}

1;
# ABSTRACT: Apply dux function conditionally

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl([cond => {if => sub { $. % 2 }, then=>'uc', else=>'lc'}], "i", "love", "perl", "and", "c");
 # => ("i", "LOVE", "perl", "AND", "c")

In command-line:

 % echo -e "i\nlove\nperl\nand\nc" | dux cond --if '$. % 2' --then uc --else lc
 i
 LOVE
 perl
 AND
 c

=cut
