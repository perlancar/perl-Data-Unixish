package Data::Unixish::List;

use 5.010;
use strict;
use warnings;
#use Log::Any '$log';

use Module::Load;
use SHARYANTO::Package::Util qw(package_exists);

# VERSION

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(dux aduxa aduxl lduxa lduxl);

sub _dux {
    my $accepts = shift;
    my $returns = shift;

    my $f = shift;
    my $out = [];
    my %args = (in => $accepts eq 'l' ? \@_ : $_[0], out => $out);
    if (ref($f) eq 'ARRAY') {
        $args{$_} = $f->[1]{$_} for keys %{$f->[1]};
        $f = $f->[0];
    }

    my $pkg = "Data::Unixish::$f";
    load $pkg unless package_exists($pkg);
    my $fleaf = $f; $fleaf =~ s/.+:://;
    my $fn = "Data::Unixish::$f\::$fleaf";
    die "Subroutine &$fn not defined" unless defined &$fn;

    no strict 'refs';
    my $res = $fn->(%args);
    die "Dux function $fn failed: $res->[0] - $res->[1]"
        unless $res->[0] == 200;

    if ($returns eq 'l') {
        if (wantarray) {
            return @$out;
        } else {
            return $out->[0];
        }
    } else {
        return $out;
    }
}

sub dux   { _dux('l', 'l', @_) }
sub aduxa { _dux('a', 'a', @_) }
sub aduxl { _dux('a', 'l', @_) }
sub lduxa { _dux('l', 'a', @_) }
sub lduxl { _dux('l', 'l', @_) }

1;
# ABSTRACT: Apply dux function to a list/array (and return result as list/array)

=head1 SYNOPSIS

 # prefix 'a'/'l' determines whether function accepts arrayref or list.
 # suffix 'a'/'l' determines whether function returns arrayref or list.
 use Data::Unixish::List qw(aduxa aduxl lduxa lduxl);

 # no dux function arguments
 my @res = lduxl('sort', 3, 7, 1, 2); # => (1, 2, 3, 7)

 # specify dux function arguments
 my $res = aduxa([lpad => {width=>3, char=>'0'}], [3, 7, 1]); # => ['003', '007', '001']

 # only retrieve the first row
 my @nums = (1, 2, 3, 4, "a", 5);
 my $sum  = aduxl(sum => \@nums); # => 15


=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 aduxa($func, \@data) => ARRAYREF

=head2 aduxl($func, @data) => ARRAYREF

=head2 lduxa($func, \@data) => LIST (OR SCALAR)

=head2 lduxl($func, @data) => LIST (OR SCALAR)

Apply dux function C<$func> to C<@data>. Return the result list. If called in
scalar context, return the first row of result list.

C<$func> is either a string containing the name of dux function (without the
C<Data::Unixish::> prefix) or a 2-element array like C<[$fname, \%args]> where
the first element is the dux function name and the second element contains the
arguments for the function. If you do not need to pass any arguments/options to
the dux function, you can use the simpler string version.


=head1 SEE ALSO

L<Data::Unixish::Apply>
