package Data::Unixish::File;

use 5.010;
use strict;
use warnings;
#use Log::Any '$log';

use Module::Load;
use SHARYANTO::Package::Util qw(package_exists);
use Tie::File;

# VERSION

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(fduxl);

sub fduxl {
    my $func = shift;

    my @ary;
    tie @ary, 'Tie::File', @_;

    my $out = [];
    my %args = (in => \@ary, out => $out);
    if (ref($func) eq 'ARRAY') {
        $args{$_} = $func->[1]{$_} for keys %{$func->[1]};
        $func = $func->[0];
    }

    my $pkg = "Data::Unixish::$func";
    load $pkg unless package_exists($pkg);
    my $funcleaf = $func; $funcleaf =~ s/.+:://;
    my $funcname = "Data::Unixish::$func\::$funcleaf";
    die "Subroutine &$funcname not defined" unless defined &$funcname;

    no strict 'refs';
    my $res = $funcname->(%args);
    die "Dux function $funcname failed: $res->[0] - $res->[1]"
        unless $res->[0] == 200;

    if (wantarray) {
        return @$out;
    } else {
        return $out->[0];
    }
}

1;
# ABSTRACT: Apply dux function to lines of a file/filehandle

=head1 SYNOPSIS

 use Data::Unixish::File qw(fduxl);

 # Given this file ...
 % cat filename
 1
 3
 2
 7

 # no dux function arguments
 my @res = fduxl('sort', "filename"); # => (1, 2, 3, 7)

 # specify dux function arguments
 my @res = fduxl([lpad => {width=>3, char=>'0'}], "filename"); # => ('003', '007', '001')

 # only retrieve the first row
 my $sum  = fduxl(sum => "filename"); # => 13

 # use filehandle instead of filename
 open my($fh), "<", "filename";
 my @res = fduxl('sort', $fh); # => (1, 2, 3, 7)


=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 fduxl($func, $file, @args) => LIST (OR SCALAR)

Apply dux function C<$func> to file/filehandle C<$file>. Return the result list.
If called in scalar context, return the first row of result list. C<@args> is
optional and will be passed to L<Tie::File>.

C<$func> is either a string containing the name of dux function (without the
C<Data::Unixish::> prefix) or a 2-element array like C<[$funcname, \%args]>
where the first element is the dux function name and the second element contains
the arguments for the function. If you do not need to pass any arguments/options
to the dux function, you can use the simpler string version.


=head1 TODO

Function C<fduxf> which is similar to C<fduxl> but instead of returning a list,
returns a filehandle that can be read from. Like in L<App::dux>, it should be
streaming, i.e. it returns the result filehandle immediately. Reading the
filehandle will execute the dux function as needed.


=head1 SEE ALSO

L<Data::Unixish::List>

L<Data::Unixish::Apply>
