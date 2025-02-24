package Data::Unixish::chain;

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

$SPEC{chain} = {
    v => 1.1,
    summary => 'Chain several dux functions together',
    description => <<'MARKDOWN',

Currently works for itemfunc only.

See also the <pm:Data::Unixish::Apply> function, which is related.

MARKDOWN
    args => {
        %common_args,
        functions => {
            summary => 'The functions to chain',
            schema  => ['array*' => of => ['any*', of => [
                'str*',
                ['array*', min_len=>1, elems=>['str*','hash*']],
            ]]],
            description => <<'MARKDOWN',

Each element must either be function name (like `date`) or a 2-element array
containing the function name and its arguments (like `[bool, {style: dot}]`).

MARKDOWN
            req     => 1,
            pos     => 0,
            greedy  => 1,
            cmdline_aliases => {f => {}},
        },
    },
    tags => [qw/itemfunc func/],
};
sub chain {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    _chain_begin(\%args);
    local ($., $_);
    while (($., $_) = each @$in) {
        push @$out, _chain_item($_, \%args);
    }

    [200, "OK"];
}

sub _chain_begin {
    no strict 'refs'; ## no critic: TestingAndDebugging::ProhibitNoStrict

    my $args = shift;
    my $ff = [];
    for my $f (@{ $args->{functions} }) {
        my ($fn, $args);
        if (ref($f) eq 'ARRAY') {
            $fn = $f->[0];;
            $args = $f->[1];
        } else {
            $fn = $f;
            $args = {};
        }
        unless ($fn =~
                    /\A[A-Za-z_][A-Za-z0-9_]*(::[A-Za-z_][A-Za-z0-9_]*)*\z/) {
            die "Invalid function name $fn, please use letter+alphanums only";
        }
        my $mod = "Data::Unixish::$fn";
        unless (eval "require $mod") { ## no critic: BuiltinFunctions::ProhibitStringyEval
            die "Can't load dux function $fn: $@";
        }
        my $fnleaf = $fn; $fnleaf =~ s/.+:://;
        if (defined &{"$mod\::_${fnleaf}_begin"}) {
            my $begin = \&{"$mod\::_${fnleaf}_begin"};
            $begin->($args);
        }
        push @$ff, [$mod, $fn, $fnleaf, \&{"$mod\::_${fnleaf}_item"}, $args];
    }
    # abuse to store state
    $args->{-functions} = $ff;
}

sub _chain_item {
    my ($item, $args) = @_;
    local $_ = $item;
    for my $f (@{ $args->{-functions} }) {
        $item = $f->[3]->($item, $f->[4]);
    }
    $item;
}

sub _chain_end {
    no strict 'refs'; ## no critic: TestingAndDebugging::ProhibitNoStrict

    my $args = shift;
    for my $f (@{ $args->{-functions} }) {
        my $mod    = $f->[0];
        my $fnleaf = $f->[2];
        my $args   = $f->[4];
        if (defined &{"$mod\::_${fnleaf}_end"}) {
            my $end = \&{"$mod\::_${fnleaf}_end"};
            $end->($args);
        }
    }
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 my @res = lduxl([chain => {functions => ['date', ["ANSI::color" => {color=>"yellow"}]]}], 1000, 2000);

In command-line:

 % echo -e "1000\n2000" | dux chain --functions-json '["date", ["ANSI::color",{"color":"yellow"}]]'
 2
 3
 4

=cut
