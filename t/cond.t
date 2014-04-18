#!/perl

use 5.010;
use strict;
use utf8;
use warnings;
use Test::Data::Unixish;
use Test::More 0.96;

test_dux_func(
    func => 'cond',
    tests => [
        {
            name => 'index',
            args => { if => sub { $. % 2 }, then => 'uc', else => 'lc' },
            in   => [ "A", "b", "c", "d" ],
            out  => [ "a", "B", "c", "D" ],
            skip_itemfunc => 1,
        },
        {
            name => 'accept code string',
            args => { if => 'length($_) < 5', then => [trunc => {width=>3}] },
            in   => [ "i", "love", "perl", "and", "javascript"  ],
            out  => [ "i", "lov", "per", "and", "javascript" ],
        },
    ],
);

done_testing;
