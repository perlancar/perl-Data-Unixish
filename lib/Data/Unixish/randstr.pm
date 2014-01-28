package Data::Unixish::randstr;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
# VERSION

our %SPEC;

my $def_charset = 'AZaz09';
my %charsets = (
    '09'     => '0123456789',
    'AZ'     => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'az'     => 'abcdefghijklmnopqrstuvwxyz',
    'AZaz'   => 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',
    'AZaz09' => 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
);
my $charsets_desc = <<'_';

`az` is basic Latin lowercase letters. `AZ` uppercase letters. `AZaz` lowercase
and uppercase letters. `AZaz09` lowercase + uppercase letters + Arabic numbers.
`09` numbers.

_

$SPEC{randstr} = {
    v => 1.1,
    summary => 'Generate a stream of random strings',
    args => {
        %common_args,
        min_len => {
            summary => 'Minimum possible length (inclusive)',
            schema => ['int*', min=>0, default=>16],
            cmdline_aliases => { a=>{} },
        },
        max_len => {
            summary => 'Maximum possible length (inclusive)',
            schema => ['int*', min=>0, default=>16],
            cmdline_aliases => {
                b => {},
                c => {
                    summary => 'Set length (min_len and max_len)',
                    code => sub {
                        my ($args, $val) = @_;
                        $args->{min_len} = $val;
                        $args->{max_len} = $val;
                    },
                },
            },
        },
        charset => {
            summary => 'Character set to use',
            description => $charsets_desc,
            schema => ['str*', default=>$def_charset,
                       in=>[sort keys %charsets]],
        },
        num => {
            summary => 'Number of strings to generate, -1 means infinite',
            schema => ['int*', default=>1],
            cmdline_aliases => { n=>{} },
        },
    },
    tags => [qw/text gen-data/],
    'x.dux.is_stream_output' => 1,
};
sub randstr {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    # XXX schema
    my $min_len   = $args{min_len} // 16; $min_len = 0 if $min_len < 0;
    my $max_len   = $args{max_len} // 16; $max_len = 0 if $max_len < 0;
    my $charset   = $args{charset};
    my $chars     = $charsets{$charset};
    return [400, "Unknown charset"] unless defined($chars);
    my $len_chars = length($chars);
    my $num       = $args{num} // 1;

    my $i = 0;
    while (1) {
        last if $num >= 0 && ++$i > $num;
        my $len = $min_len + int(rand()*($max_len-$min_len+1));
        my $rand = join "", map {substr($chars, $len_chars*rand(), 1)} 1..$len;
        push @$out, $rand;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Generate a stream of random strings

=head1 SYNOPSIS

In command line:

 % dux randstr
 trWFSsAwZH4Cli90

 % dux randstr --min-len 1 --max-len 5 --charset AZ -n 5
 WXY
 KQDCG
 MGS
 QMEH
 JDOCK


=head1 TODO

More choices in character sets: full ASCII, Unicode, etc.

Allow users to specify their own charset.

=head1 SEE ALSO

=cut
