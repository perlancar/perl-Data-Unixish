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
                       aduxf fduxf lduxf
                       aduxl fduxl lduxl
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
        die "Invalid accepts, must be a|f|l";
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

    my @out;
    my $kidfh;
    my $pid;
    if ($returns eq 'c') {
        require Tie::Simple;
        tie @out, "Tie::Simple", undef,
            PUSH => sub {
                my $data = shift; # for Tie::Simple
                $callback->($_) for @_;
            };
        $args{out} = \@out;
    } elsif ($returns eq 'f') {
        require Tie::Simple;
        tie @out, "Tie::Simple", undef,
            PUSH => sub {
                my $data = shift; # for Tie::Simple
                for my $item (@_) {
                    $item .= "\n" unless $item =~ /\n\z/;
                    print STDOUT $item;
                }
            };
        $args{out} = \@out;
        $pid = open $kidfh, "-|";
        defined $pid or die "Can't fork: $!";
    } else {
        $args{out} = \@out;
    }

    unless ($pid) {
        no strict 'refs';
        my $res = $funcname->(%args);
        die "Dux function $funcname failed: $res->[0] - $res->[1]"
            unless $res->[0] == 200;
    }

    if ($returns eq 'l') {
        if (wantarray) {
            return @out;
        } else {
            return $out[0];
        }
    } elsif ($returns eq 'a') {
        return \@out;
    } elsif ($returns eq 'c') {
        return;
    } elsif ($returns eq 'f') {
        if ($pid) {
            return $kidfh;
        } else {
            exit;
        }
    } else {
        die "Invalid returns, must be a|c|f|l";
    }
}

sub aduxa { _dux('a', 'a', @_) }
sub fduxa { _dux('f', 'a', @_) }
sub lduxa { _dux('l', 'a', @_) }

sub aduxc { _dux('a', 'c', @_) }
sub fduxc { _dux('f', 'c', @_) }
sub lduxc { _dux('l', 'c', @_) }

sub aduxf { _dux('a', 'f', @_) }
sub fduxf { _dux('f', 'f', @_) }
sub lduxf { _dux('l', 'f', @_) }

sub aduxl { _dux('a', 'l', @_) }
sub fduxl { _dux('f', 'l', @_) }
sub lduxl { _dux('l', 'l', @_) }

1;
# ABSTRACT: Implementation for Unixish, a data transformation framework

=head1 SYNOPSIS

 # the a/f/l prefix determines whether function accepts
 # arrayref/file(handle)/list as input. the a/f/l/c suffix determines whether
 # function returns an array, a list, a filehandle, or calls a callback. If
 # filehandle is selected, a child process is forked to

 use Data::Unixish qw(
                       aduxa fduxa lduxa
                       aduxc fduxc lduxc
                       aduxf fduxf lduxf
                       aduxl fduxl lduxl
 );

 # apply function, without argument
 my @out = lduxl('sort', 7, 2, 4, 1);  # => (1, 2, 4, 7)
 my $out = lduxa('uc', "a", "b", "c"); # => ["A", "B", "C"]
 my $res = fduxl('wc', "file.txt");    # => "12\n234\n2093" # like wc's output

 # apply function, with some arguments
 my $fh = fduxf([trunc => {width=>80, ansi=>1, mb=>1}], \*STDIN);
 say while <$fh>;


=head1 DESCRIPTION

This distribution implements L<Unixish>, a data transformation framework
inspired by Unix toolbox philosophy.


=head1 FUNCTIONS

=head2 aduxa($func, \@input) => ARRAYREF

=head2 aduxc($func, $callback, \@input)

=head2 aduxf($func, \@input) => FILEHANDLE

=head2 aduxl($func, \@input) => LIST (OR SCALAR)

The C<adux*> functions accept an arrayref as input. C<$func> is a string
containing dux function name (if no arguments to the dux function is to be
supplied), or C<< [$func, \%args] >> to supply arguments to the dux function.
Dux function name corresponds to module names C<Data::Unixish::NAME> without the
prefix.

The C<*duxc> functions will call the callback repeatedly with every output item.

The C<*duxf> functions returns filehandle immediately. A child process is
forked, and dux function is run in the child process. You read output as lines
from the returned filehandle.

The C<*duxl> functions returns result as list. It can be evaluated in scalar to
return only the first element of the list. However, the whole list will be
calculated first. Use C<*duxf> for streaming interface.

=head2 fduxa($func, $file_or_handle, @args) => ARRAYREF

=head2 fduxc($func, $callback, $file_or_handle, @args)

=head2 fduxf($func, $file_or_handle, @args) => FILEHANDLE

=head2 fduxl($func, $file_or_handle, @args) => LIST

The C<fdux*> functions accepts filename or filehandle. C<@args> is optional and
will be passed to L<Tie::File>.

=head2 lduxa($func, @input) => ARRAYREF

=head2 lduxc($func, $callback, @input)

=head2 lduxf($func, @input) => FILEHANDLE

=head2 lduxl($func, @input) => LIST

The C<ldux*> functions accepts list as input.


=head1 FAQ

=head2 How do I use the diamond operator as input?

You can use L<Tie::Diamond>, e.g.:

 use Tie::Diamond;
 tie my(@in), "Tie::Diamond";
 my $out = aduxa($func, \@in);

Also see the L<dux> command-line utility in the L<App::dux> distribution which
allows you to access dux function from the command-line.


=head1 SEE ALSO

L<Unixish>

L<dux> script in L<App::dux>

=cut
