#!/usr/bin/perl
use strict;
use warnings;
use DDP;
use 5.018;
die "Bad arguments" unless @ARGV;
die "Bad arguments" if @ARGV > 3;
die "not quadratic equation" if ($ARGV[0] == 0);
my ($a,$b,$c);
if (@ARGV == 1) {
	$a = $ARGV[0];
	$b = 0;
	$c = 0;
} 
elsif (@ARGV == 2) {
	$a = $ARGV[0];
	$b = $ARGV[1];
	$c = 0;
}
elsif (@ARGV == 3) {
	$a = $ARGV[0];
	$b = $ARGV[1];
	$c = $ARGV[2];
}

my ($x1, $x2);
my $diskr = $b**2 - 4*$a*$c;

if ($diskr >= 0) {
	$x1 = (-$b + sqrt($diskr))/(2*$a);
	$x2 = (-$b - sqrt($diskr))/(2*$a);
}
else {
	my $buf = sqrt(-$diskr);
	my $first = $b/(2*$a);
	my $second = $buf/(2*$a);
	$x1 = "-$first + i*$second";
	$x2 = "-$first - i*$second";
}
if ($diskr != 0){
	say "$x1, $x2";
}
else {
	say "$x1";
}