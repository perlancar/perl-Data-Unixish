package Test::Data::Unixish;

use 5.010;
use strict;
use warnings;
use experimental 'smartmatch';

use Data::Unixish qw(aiduxa);
use Test::More 0.96;
use Module::Load;

# VERSION

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(test_dux_func);

sub test_dux_func {
    no strict 'refs';

    my %args = @_;
    my $fn  = $args{func};
    my $fnl = $fn; $fnl =~ s/.+:://;
    load "Data::Unixish::$fn";
    my $f = "Data::Unixish::$fn\::$fnl";
    my $spec = \%{"Data::Unixish::$fn\::SPEC"};
    my $meta = $spec->{$fn};

    $meta or die "BUG: func $fn not found or does not have meta";

    my $i = 0;
    subtest $fn => sub {
        for my $t (@{$args{tests}}) {
            $i++;
            my $tn = $t->{name} // "test[$i]";
            subtest $tn => sub {
                if ($t->{skip}) {
                    my $msg = $t->{skip}->();
                    plan skip_all => $msg if $msg;
                }
                my $in   = $t->{in};
                my $out  = $t->{out};
                my $rout = [];
                my $res  = $f->(in=>$in, out=>$rout, %{$t->{args}});
                is($res->[0], 200, "status");
                is_deeply($rout, $out, "out")
                    or diag explain $rout;

                # if itemfunc, test against each item
                if ('itemfunc' ~~ @{$meta->{tags}} && ref($in) eq 'ARRAY') {
                    if ($t->{skip_itemfunc}) {
                        diag "itemfunc test skipped";
                    } else {
                        my $rout = aiduxa([$fn, $t->{args}], $in);
                        is_deeply($rout, $out, "itemfunc")
                            or diag explain $rout;
                    }
                }
            };
        }
    };
}

1;
# ABSTRACT: Routines to test Data::Unixish

=for Pod::Coverage .+

=cut
