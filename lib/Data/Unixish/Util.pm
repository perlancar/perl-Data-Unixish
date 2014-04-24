package Data::Unixish::Util;

# VERSION

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(%common_args filter_args);

our %common_args = (
    in  => {
        summary => 'Input stream (e.g. array or filehandle)',
        schema  => 'any', # TODO: any* => of => [stream*, array*]
        #req => 1,
    },
    out => {
        summary => 'Output stream (e.g. array or filehandle)',
        schema  => 'any', # TODO: any* => of => [stream*, array*]
        #req => 1,
    },
);

sub filter_args {
    my $hash = shift;
    return { map {$_=>$hash->{$_}} grep {/\A\w+\z/} keys %$hash };
}

1;
#ABSTRACT: Utility routines

=head1 EXPORTS

C<%common_args>


=head1 FUNCTIONS

=head2 filter_args

=cut
