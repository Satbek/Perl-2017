#!/usr/bin/env perl
use 5.016;
use warnings;
use DDP;
die 'bad arguments' if (@ARGV != 1);
my $n = shift @ARGV;
die 'not natural' if ($n < 1 or ($n - int($n) != 0));

my @prime;
push @prime, 1 for (1..$n + 1); 

$prime[0] = $prime[1] = 0;
for my $i(2..$n) {
	if ($prime[$i]) {
		if ($i * $i <= $n) {
			for (my $j = $i*$i; $j <= $n; $j += $i) {
				$prime[$j] = 0;
			}
		}
	}
}

for my $i(1..$n) {
	print $i." " if $prime[$i];
}
print "\n";