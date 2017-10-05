#!/usr/bin/env perl

use 5.016;
use warnings;
use strict;

die "Bad aruments" if (@ARGV != 1);
my $n = $ARGV[0];
die "not natural" if ($n - int($n) != 0 or $n < 1);

my $res = 1;
for my $i (1..$n) {
	$res *= $i;
}

say $res;
