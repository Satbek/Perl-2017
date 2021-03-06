#!/usr/bin/perl
use 5.016;
use warnings;
use DDP;
die "Bad arguments" unless @ARGV;
die "Bad arguments" if @ARGV > 3;
die "not quadratic equation" if ($ARGV[0] == 0);
die "Icorrect input" if (@ARGV < 1 or @ARGV > 3);

my ($a,$b,$c) = @ARGV;
$_ //= 0 for ($a, $b, $c);


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