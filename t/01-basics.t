#!/perl

use 5.010;
use strict;
use warnings;

use Data::Unixish qw(
                       aduxa fduxa lduxa
                       aduxc fduxc lduxc
                       aduxl fduxl lduxl
                       aduxp fduxp lduxp
                       aduxP fduxP lduxP
                );
use File::Temp qw(tempfile);
use Test::More 0.98;

my $filename;
{
    my $fh;
    ($fh, $filename) = tempfile();
    for ("d", "a", "c", "b") { print $fh "$_\n" }
    close $fh;
}

subtest "a, l" => sub {
    is_deeply( [lduxl('sort',  1, 3, 2)],  [1, 2, 3]);
    is_deeply(  aduxa('sum' , [1, 2, 3, 4, 5]), [15]);
    is_deeply(  lduxa([lpad => {width=>2, char=>"0"}],  3, 2, 5, 1, 4 ), ["03", "02", "05", "01", "04"]);
    is_deeply(~~aduxl([lpad => {width=>2, char=>"0"}], [3, 2, 5, 1, 4]) , "03");
};

subtest "c" => sub {
    my @a;

    @a = (); aduxc('sort', sub { push @a, shift }, [1, 3, 2]);
    is_deeply(\@a, [1, 2, 3]);

    @a = (); lduxc('sort', sub { push @a, shift }, 1, 3, 2);
    is_deeply(\@a, [1, 2, 3]);

    @a = (); fduxc('sort', sub { push @a, shift }, $filename);
    is_deeply(\@a, [qw/a b c d/]);
};

subtest "f" => sub {
    is_deeply( fduxa('sort', $filename) , [qw/a b c d/]);
    is_deeply([fduxl('sort', $filename)], [qw/a b c d/]);
};

done_testing;
