package Data::Unixish::wc;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);

# VERSION

our %SPEC;

$SPEC{wc} = {
    v => 1.1,
    summary => 'Print newline, word, and byte counts',
    description => <<'_',

Behavior mimics that of the Unix `wc` utility. The order of the counts which is
returned is always: newline, word, character, byte, maximum line length.

_
    args => {
        %common_args,
        bytes => {
            summary => "Return the bytes counts",
            schema => [bool => default => 0],
            cmdline_aliases => { c => {} },
        },
        chars => {
            summary => "Return the character counts",
            schema => [bool => default => 0],
            cmdline_aliases => { m => {} },
        },
        words => {
            summary => "Return the word counts",
            schema => [bool => default => 0],
            cmdline_aliases => { w => {} },
        },
        lines => {
            summary => "Return the newline counts",
            schema => [bool => default => 0],
            cmdline_aliases => { l => {} },
        },
        max_line_length => {
            summary => "Return the length of the longest line",
            schema => [bool => default => 0],
            cmdline_aliases => { L => {} },
        },
    },
    tags => [qw/text group/],
    "x.dux.strip_newlines" => 0,
    "x.perinci.cmdline.default_format" => "text-simple",
};
sub wc {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    my ($bytes, $chars, $words, $lines);
    my $maxllen = 0;
    while (my ($index, $item) = each @$in) {
        next if !defined($item) || ref($item);
        for my $line (split /^/, $item) {
            $lines++;
            $chars += length($line);
            { use bytes; $bytes += length($line) }
            my @w = split /[ \t]+/o, $line; $words += @w;

            chomp($line);
            my $llen;
            { use bytes; $llen = length($line) }
            $maxllen = $llen if $llen > $maxllen;
        }
    }

    my $pbytes   = $args{bytes};
    my $pchars   = $args{chars};
    my $pwords   = $args{words};
    my $plines   = $args{lines};
    my $pmaxllen = $args{max_line_length};
    if (!$pbytes && !$pchars && !$pwords && !$plines && !$pmaxllen) {
        $pbytes++; $pwords++; $plines++;
    }
    my @res;
    push @res, $lines   if $plines;
    push @res, $words   if $pwords;
    push @res, $chars   if $pchars;
    push @res, $bytes   if $pbytes;
    push @res, $maxllen if $pmaxllen;

    push @$out, join("\t", @res);
    [200, "OK"];
}

1;
# ABSTRACT: Print newline, word, and byte counts

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 my @text = split /^/, "What do you want?\nWhat do you want me to want?\n";
 my $res = dux([wc => {words=>1, lines=>1}], @text); # => "2\t11"

In command line:

 % seq 1 100 | dux wc
 100    100    292


=head1 SEE ALSO

wc(1)

=cut
