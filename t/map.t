#!/perl

use 5.010;
use strict;
use utf8;
use warnings;
use Test::Data::Unixish;
use Test::More 0.96;

local $ENV{LANG} = "C";

test_dux_func(
    func => 'map',
    tests => [
        {
            name => 'simple',
            args => { callback => sub { int($_) } },
            in   => [ "2.2", "3.3", "4.4", "5.5" ],
            out  => [ 2 .. 5 ],
        },
        {
            name => 'index',
            args => { callback => sub { int($.) } },
            in   => [ "2.2", "3.3", "4.4", "5.5" ],
            out  => [ 0 .. 3 ],
        },
        {
            name => 'returning a list',
            args => { callback => sub { split /\./ } },
            in   => [ "2.2", "3.3", "4.4", "5.5" ],
            out  => [ 2, 2, 3, 3, 4, 4, 5, 5 ],
        },
    ],
);

done_testing;
