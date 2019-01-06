## no critic: (Modules::ProhibitAutomaticExportation)

package Test::Data::Unixish;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Data::Unixish qw(aiduxa);
use File::Which qw(which);
use IPC::Cmd qw(run_forked);
use JSON::MaybeXS;
use Module::Load;
use String::ShellQuote;
use Test::More 0.96;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(test_dux_func);

my $json = JSON::MaybeXS->new->allow_nonref;

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
      TEST:
        for my $t (@{$args{tests}}) {
            $i++;
            my $tn = $t->{name} // "test[$i]";
            subtest $tn => sub {
                if ($t->{skip}) {
                    my $msg = $t->{skip}->();
                    plan skip_all => $msg if $msg;
                }

                # test func
                if ($t->{skip_func}) {
                    diag "func test skipped";
                } else {
                    subtest "func" => sub {
                        my $in   = $t->{in};
                        my $out  = $t->{out};
                        my $rout = [];
                        my $res;
                        eval { $res = $f->(in=>$in,out=>$rout,%{$t->{args}}) };
                        my $err = $@;
                        if ($t->{func_dies} // $t->{dies} // 0) {
                            ok($err, "dies");
                            return;
                        } else {
                            ok(!$err, "doesn't die") or do {
                                diag "func dies: $err";
                                return;
                            };
                        }
                        is($res->[0], 200, "status");
                        if ($t->{test_out}) {
                            $t->{test_out}->($rout);
                        } else {
                            is_deeply($rout, $out, "out")
                            or diag explain $rout;
                        }

                        # if itemfunc, test against each item
                        if ((grep {$_ eq 'itemfunc'} @{$meta->{tags}}) &&
                                ref($in) eq 'ARRAY') {
                            if ($t->{skip_itemfunc}) {
                                diag "itemfunc test skipped";
                            } else {
                                my $rout;
                                $rout = aiduxa([$fn, $t->{args}], $in);
                                if ($t->{test_out}) {
                                    $t->{test_out}->($rout);
                                } else {
                                    is_deeply($rout, $out, "out")
                                        or diag explain $rout;
                                }
                            }
                        }
                    };
                }

                # test running through cmdline
                if ($t->{skip_cli} // 1) {
                    #diag "cli test skipped";
                } else {
                    subtest cli => sub {
                        if ($^O =~ /win/i) {
                            plan skip_all => "run_forked() not available ".
                                "on Windows";
                            return;
                        }
                        unless (which("dux")) {
                            plan skip_all => "dux command-line not available, ".
                                "you might want to install App::dux first";
                            return;
                        }
                        my $cmd = "dux $fn ".
                            join(" ", map {
                                my $v = $t->{args}{$_};
                                my $p = $_; $p =~ s/_/-/g;
                                ref($v) ?
                                    ("--$p-json",
                                     shell_quote($json->encode($v))) :
                                    ("--$p", shell_quote($v))
                                }
                                     keys %{ $t->{args} });
                        #diag "cmd: $cmd";
                        my %runopts = (
                            child_stdin => join("", map {"$_\n"} @{ $t->{in} }),
                        );
                        my $res = run_forked($cmd, \%runopts);
                        if ($t->{cli_dies} // $t->{dies} // 0) {
                            ok($res->{exit_code}, "dies");
                            return;
                        } else {
                            ok(!$res->{exit_code}, "doesn't die") or do {
                                diag "dux dies ($res->{exit_code})";
                                return;
                            };
                        }
                        is_deeply(join("", map {"$_\n"} @{ $t->{out} }),
                                       $res->{stdout}, "output");
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
