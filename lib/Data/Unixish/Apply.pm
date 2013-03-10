package Data::Unixish::Apply;

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

use SHARYANTO::Package::Util qw(package_exists);
use Module::Load;

# VERSION

our %SPEC;

$SPEC{apply} = {
    v => 1.1,
    summary => 'Apply one or more dux functions',
    args => {
        in => {
            schema => ['any'], # XXX stream
            req => 1,
        },
        functions => {
            summary => 'Function(s) to apply',
            schema => ['any*', of => [
                'str*',
                ['array*', of => ['any' => of => [['str*'], ['array*']]]],
            ]],
            req => 1,
            description => <<'_',

A list of functions to apply. Each element is either a string (function name),
or a 2-element array (function names + arguments hashref). If you do not want to
specify arguments to a function, you can use a string.

Example:

    [
        'sort', # no arguments (all default)
        'date', # no arguments (all default)
        ['head', {items=>5}], # specify arguments
    ]

_
        },

    },
};
sub apply {
    my %args = @_;
    my $in0 = $args{in}        or return [400, "Please specify in"];
    my $ff0 = $args{functions} or return [400, "Please specify functions"];
    $ff0 = [$ff0] unless ref($ff0) eq 'ARRAY';

    # special case
    unless (@$ff0) {
        return [200, "No processing done", $in0];
    }

    my @ff;
    my ($in, $out);
    for my $i (0..@$ff0-1) {
        my $f = $ff0->[$i];
        #$log->tracef("Applying dux function %s ...", $f);
        my ($fn0, $fargs);
        if (ref($f) eq 'ARRAY') {
            $fn0 = $f->[0];
            $fargs = $f->[1] // {};
        } else {
            $fn0 = $f;
            $fargs = {};
        }

        if ($i == 0) {
            $in = $in0;
        } else {
            $in = $out;
        }
        $out = [];

        # XXX load all functions before applying, like in Unix pipes
        my $pkg = "Data::Unixish::$fn0";
        unless (package_exists($pkg)) {
            eval { load $pkg; 1 } or
                return [500,
                        "Can't load package for dux function $fn0: $@"];
        }

        my $fnl = $fn0; $fnl =~ s/.+:://;
        my $fn = "Data::Unixish::$fn0\::$fnl";
        return [500, "Subroutine &$fn not defined"] unless defined &$fn;

        no strict 'refs';
        my $res = $fn->(%$fargs, in=>$in, out=>$out);
        unless ($res->[0] == 200) {
            return [500, "Function $fn0 did not return success: ".
                        "$res->[0] - $res->[1]"];
        }
    }

    [200, "OK", $out];
}

1;
# ABSTRACT: Apply one or more dux functions to data

=head1 SYNOPSIS

 use Data::Unixish::Apply;
 Data::Unixish::Apply::apply(
     in => [1, 4, 2, 6, 7, 10],
     functions => ['sort', ['printf', {fmt=>'%04d'}]],
 ); # will result in [qw/0001 0002 0004 0006 0007 0010/],


=head1 DESCRIPTION

