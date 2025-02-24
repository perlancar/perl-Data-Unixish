package Data::Unixish::map;

use 5.010;
use locale;
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

$SPEC{map} = {
    v => 1.1,
    summary => 'Perl map',
    description => <<'MARKDOWN',

Process each item through a callback.

MARKDOWN
    args => {
        %common_args,
        callback => {
            summary => 'The callback coderef to use',
            schema  => ['any*' => of => ['code*', 'str*']],
            req     => 1,
            pos     => 0,
        },
    },
    tags => [qw/perl unsafe itemfunc/],
};
sub map {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    _map_begin(\%args);
    local ($., $_);
    while (($., $_) = each @$in) {
        push @$out, $args{callback}->();
    }

    [200, "OK"];
}

sub _map_begin {
    my $args = shift;

    if (ref($args->{callback}) ne 'CODE') {
        if ($args->{-cmdline}) {
            $args->{callback} = eval "no strict; no warnings; sub { $args->{callback} }"; ## no critic: BuiltinFunctions::ProhibitStringyEval
            die "invalid Perl code for map: $@" if $@;
        } else {
            die "Please supply coderef for 'callback'";
        }
    }
}

sub _map_item {
    my ($item, $args) = @_;
    local $_ = $item;
    $args->{callback}->();
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl([map => {callback => sub { 1 + $_ }}], 1, 2, 3);
 # => (2, 3, 4)

In command-line:

 % echo -e "1\n2\n3" | dux map '1 + $_'
 2
 3
 4

=cut
