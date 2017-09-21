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

my $diskr = $b**2 - 4*$a*$c;

die "equation has no answer" if ($diskr < 0);

my $x1 = (-$b + sqrt($diskr))/(2*$a);
my $x2 = (-$b - sqrt($diskr))/(2*$a);

if ($diskr != 0){
	say "$x1, $x2";
}
else {
	say "$x1";
}