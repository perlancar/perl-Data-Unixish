package Data::Unixish;

use 5.010001;
use strict;
use warnings;

use Module::Load;
use SHARYANTO::Package::Util qw(package_exists);

# VERSION

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(
                       aduxa fduxa lduxa
                       aduxc fduxc lduxc
                       aduxl fduxl lduxl
                       aduxp fduxp lduxp
                       aduxP fduxP lduxP
               );

sub _dux {
    my $accepts = shift;
    my $returns = shift;

    my $func = shift;

    my $callback;
    if ($returns eq 'c') {
        $callback = shift;
    }

    my %args;

    my $in;
    if ($accepts eq 'f') {
        require Tie::File;
        my @in;
        tie @in, "Tie::File", @_;
        $args{in} = \@in;
    } elsif ($accepts eq 'l') {
        $args{in} = \@_;
    } elsif ($accepts eq 'a') {
        $args{in} = $_[0];
    } else {
        die "Invalid accepts value '$accepts'";
    }

    if (ref($func) eq 'ARRAY') {
        $args{$_} = $func->[1]{$_} for keys %{$func->[1]};
        $func = $func->[0];
    }

    my $pkg = "Data::Unixish::$func";
    load $pkg unless package_exists($pkg);
    my $funcleaf = $func; $funcleaf =~ s/.+:://;
    my $funcname = "Data::Unixish::$func\::$funcleaf";
    die "Subroutine &$funcname not defined" unless defined &$funcname;

    if ($returns eq 'c') {
        require Tie::Simple;
        my @out;
        tie @out, "Tie::Simple", undef,
            PUSH => sub { $callback->(shift) };
        $args{out} = \@out;
    } else {
        my $out = [];
        $args{out} = $out;
    }
    no strict 'refs';
    my $res = $funcname->(%args);
    die "Dux function $funcname failed: $res->[0] - $res->[1]"
        unless $res->[0] == 200;

    if ($returns eq 'l') {
        if (wantarray) {
            return @$out;
        } else {
            return $out->[0];
        }
    } elsif ($returns eq 'a') {
        return $out;
    } elsif ($returns eq 'c') {
        return;
    }
}

sub aduxa { _dux('a', 'a', @_) }
sub fduxa { _dux('f', 'a', @_) }
sub lduxa { _dux('l', 'a', @_) }

sub aduxc { _dux('a', 'c', @_) }
sub fduxc { _dux('f', 'c', @_) }
sub lduxc { _dux('l', 'c', @_) }

sub aduxl { _dux('a', 'l', @_) }
sub fduxl { _dux('f', 'l', @_) }
sub lduxl { _dux('l', 'l', @_) }

sub aduxp { _dux('a', 'p', @_) }
sub fduxp { _dux('f', 'p', @_) }
sub lduxp { _dux('l', 'p', @_) }

sub aduxP { _dux('a', 'P', @_) }
sub fduxP { _dux('f', 'P', @_) }
sub lduxP { _dux('l', 'P', @_) }

1;
# ABSTRACT: Implementation for Unixish, a data transformation framework

=head1 SYNOPSIS

 # the a/f/l prefix determines whether function accepts
 # arrayref/file(handle)/list as input. the a/c/l/p/P suffix determines whether
 # function returns an array, calls a callback, returns a list, or immediately
 # return a child process handle that returns lines of text, or a child process
 # handle that returns Perl data items.

 use Data::Unixish qw(
                       aduxa fduxa lduxa
                       aduxc fduxc lduxc
                       aduxl fduxl lduxl
                       aduxp fduxp lduxp
                       aduxP fduxP lduxP
 );

 # apply function, without argument
 my @out = lduxl('sort', 7, 2, 4, 1);  # => (1, 2, 4, 7)
 my $out = lduxa('uc', "a", "b", "c"); # => ["A", "B", "C"]
 my $res = fduxl('wc', "file.txt");    # => "12\n234\n2093" # like wc's output

 # apply function, with some arguments
 my $p = fduxf([trunc => {width=>80, ansi=>1, mb=>1}], \*STDIN);


=head1 DESCRIPTION

This distribution implements L<Unixish>, a data transformation framework
inspired by Unix toolbox philosophy.


=head1 FUNCTIONS

=head2 aduxa($func, \@input) => ARRAYREF

=head2 aduxc($func, $callback, \@input)

=head2 aduxl($func, \@input) => LIST (OR SCALAR)

=head2 aduxp($func, \@input) => HANDLE

=head2 aduxP($func, \@input) => HANDLE

The C<adux*> functions accept an arrayref as input. C<$func> is a string
containing dux function name (if no arguments to the dux function is to be
supplied), or C<< [$func, \%args] >> to supply arguments to the dux function.
Dux function name corresponds to module names C<Data::Unixish::NAME> without the
prefix.

The C<*duxc> functions will call the callback repeatedly with every output item.

The C<*duxp> and C<*duxP> functions returns process handle immediately. Dux
function is forked as a child process. With C<*duxp> you read output as lines,
with C<*duxP> you get output as Perl data items.

The C<*duxl> functions returns result as list. It can be evaluated in scalar to
return only the first element of the list. However, the whole list will be
calculated first. Use C<*duxf> for streaming interface.

=head2 fduxa($func, $file_or_handle, @args) => ARRAYREF

=head2 fduxc($func, $callback, $file_or_handle, @args)

=head2 fduxl($func, $file_or_handle, @args) => LIST

=head2 fduxp($func, $file_or_handle, @args) => HANDLE

=head2 fduxP($func, $file_or_handle, @args) => HANDLE

The C<fdux*> functions accepts filename or filehandle. C<@args> is optional and
will be passed to L<Tie::File>.

=head2 lduxa($func, @input) => ARRAYREF

=head2 lduxc($func, $callback, @input)

=head2 lduxl($func, @input) => LIST

=head2 lduxp($func, @input) => HANDLE

=head2 lduxP($func, @input) => HANDLE

The C<ldux*> functions accepts list as input.


=head1 FAQ

=head2 How do I use the diamond operator as input?

You can use L<Tie::Diamond>, e.g.:

 use Tie::Diamond;
 tie my(@in), "Tie::Diamond";
 my $out = aduxa($func, \@in);


=head1 SEE ALSO

L<Unixish>

=cut
