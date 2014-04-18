package Data::Unixish::grep;

use 5.010;
use locale;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{grep} = {
    v => 1.1,
    summary => 'Perl grep',
    description => <<'_',

Filter each item through a callback.

_
    args => {
        %common_args,
        callback => {
            summary => 'The callback code or regexp to use',
            schema  => ['any*' => of => ['str*', 're*', 'code*']],
            req     => 1,
            pos     => 0,
        },
    },
    tags => [qw//],
};
sub grep {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});
    my $callback = $args{callback} or die "missing callback for grep";
    if (ref($callback) eq ref(qr{})) {
        my $re = $callback;
        $callback = sub { $_ =~ $re };
    } elsif (ref($callback) ne 'CODE') {
        $callback = eval "sub { $callback }";
        die "invalid code for grep: $@" if $@;
    }

    local ($., $_);
    while (($., $_) = each @$in) {
        push @$out, $_ if $callback->();
    }

    [200, "OK"];
}

1;
# ABSTRACT: Perl grep

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 my @res = dux([grep => {callback => sub { $_ % 2 }}], 1, 2, 3, 4, 5);
 # => (1, 3, 5)

In command-line:

 % echo -e "1\n2\n3\n4\n5" | dux grep '$_ % 2'
 1
 3
 5


=head1 SEE ALSO

grep(1)

=cut
