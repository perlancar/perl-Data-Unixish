#!/perl

use 5.010;
use strict;
use warnings;
use Data::Unixish::List qw(dux aduxa aduxl lduxa lduxl lduxl);
use Test::More 0.98;

is_deeply(dux('sum', 1, 2, 3, 4, 5), 15);
is_deeply( [dux([lpad => {width=>2, char=>"0"}], 3, 2, 5, 1, 4)], ["03", "02", "05", "01", "04"]);
is_deeply(~~dux([lpad => {width=>2, char=>"0"}], 3, 2, 5, 1, 4) , "03");

is_deeply( aduxa('sort', [1, 3, 2]) , [1, 2, 3]);
is_deeply([aduxl('sort', [1, 3, 2])], [1, 2, 3]);
is_deeply( lduxa('sort',  1, 3, 2 ) , [1, 2, 3]);
is_deeply([lduxl('sort',  1, 3, 2 )], [1, 2, 3]);

done_testing;
