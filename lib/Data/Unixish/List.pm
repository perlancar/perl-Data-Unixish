package Data::Unixish::List;

use 5.010;
use strict;
use warnings;
#use Log::Any '$log';

use Data::Unixish;

# VERSION

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(dux);

sub dux { goto &Data::Unixish::lduxl }

1;
# ABSTRACT: (DEPRECATED) Apply dux function to list (and return result as list)

=head1 SYNOPSIS

 # Deprecated, please use lduxl function in Data::Unixish instead.


=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 dux($func, @input) => LIST (OR SCALAR)


=head1 SEE ALSO

L<Data::Unixish>

L<Data::Unixish::Apply>
