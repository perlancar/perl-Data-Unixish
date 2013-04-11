#!/perl

use 5.010;
use strict;
use warnings;
use Data::Unixish::List qw(dux);
use Test::More 0.98;

is_deeply(dux('sum', 1, 2, 3, 4, 5), 15);
is_deeply( [dux([lpad => {width=>2, char=>"0"}], 3, 2, 5, 1, 4)], ["03", "02", "05", "01", "04"]);
is_deeply(~~dux([lpad => {width=>2, char=>"0"}], 3, 2, 5, 1, 4) , "03");

done_testing;
