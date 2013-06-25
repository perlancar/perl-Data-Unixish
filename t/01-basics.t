#!/perl

use 5.010;
use strict;
use warnings;

use Data::Unixish qw(
                       aduxa fduxa lduxa
                       aduxc fduxc lduxc
                       aduxf fduxf lduxf
                       aduxl fduxl lduxl
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

subtest "a input" => sub {
    is_deeply(  aduxa('sum' , [1, 2, 3, 4, 5]), [15]);
    # aduxf in "f output"
    # aduxc in "c output"
    is_deeply(~~aduxl([lpad => {width=>2, char=>"0"}], [3, 2, 5, 1, 4]) , "03");
};

subtest "a output" => sub {
    # aduxa in "a input"
    # fduxa in "f input"
    # lduxa in "l input"
    ok 1;
};

subtest "l input" => sub {
    is_deeply(  lduxa([lpad => {width=>2, char=>"0"}],  3, 2, 5, 1, 4 ), ["03", "02", "05", "01", "04"]);
    # lduxc in "c output"
    # lduxf in "f output"
    # lduxl in "l output"
};

subtest "l output" => sub {
    # lduxa in "a output"
    # lduxc in "c output"
    is_deeply( [lduxl('sort',  1, 3, 2)],  [1, 2, 3]);
};

subtest "f input" => sub {
    is_deeply( fduxa('sort', $filename) , [qw/a b c d/]);
    # fduxc in "c output"
    # fduxf in "f output"
    is_deeply([fduxl('sort', $filename)], [qw/a b c d/]);
};

subtest "f output" => sub {
    my (@a, $fh);

    @a = (); $fh = aduxf('sort', [1, 3, 2]); push @a, $_ while <$fh>;
    is_deeply(\@a, ["1\n", "2\n", "3\n"]);

    @a = (); $fh = lduxf('sort', 1, 3, 2); push @a, $_ while <$fh>;
    is_deeply(\@a, ["1\n", "2\n", "3\n"]);

    @a = (); $fh = fduxf('sort', $filename); push @a, $_ while <$fh>;
    is_deeply(\@a, ["a\n", "b\n", "c\n", "d\n"]);
};

subtest "c output" => sub {
    my @a;

    @a = (); aduxc('sort', sub { push @a, shift }, [1, 3, 2]);
    is_deeply(\@a, [1, 2, 3]);

    @a = (); lduxc('sort', sub { push @a, shift }, 1, 3, 2);
    is_deeply(\@a, [1, 2, 3]);

    @a = (); fduxc('sort', sub { push @a, shift }, $filename);
    is_deeply(\@a, [qw/a b c d/]);
};

done_testing;
