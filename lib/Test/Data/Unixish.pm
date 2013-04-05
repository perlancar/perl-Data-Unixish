package Test::Data::Unixish;

use 5.010;
use strict;
use warnings;

use Test::More 0.96;
use Module::Load;

# VERSION

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(test_dux_func);

sub test_dux_func {
    my %args = @_;
    my $fn  = $args{func};
    my $fnl = $fn; $fnl =~ s/.+:://;
    load "Data::Unixish::$fn";
    my $f = "Data::Unixish::$fn\::$fnl";

    subtest $fn => sub {
        no strict 'refs';
        my $i = 0;
        for my $t (@{$args{tests}}) {
            my $tn = $t->{name} // "test[$i]";
            subtest $tn => sub {
                my $in  = $t->{in};
                my $out = [];
                my $res = $f->(in=>$in, out=>$out, %{$t->{args}});
                is($res->[0], 200, "status");
                is_deeply($out, $t->{out}, "out")
                    or diag explain $out;
            };
            $i++;
        }
    };
}

1;
# ABSTRACT: Routines to test Data::Unixish

=for Pod::Coverage .+

=cut
