#!/usr/bin/env perl
use 5.016;
use warnings;

=f
## Посчитать число Фибоначчи натурального числа N

* В качестве аргумента программа принимает натуральное число
* На выход печатает значение числа Фибоначчи
* Программа должна проверять, что число натуральное. Если число не натуральное - печатаем ошибку.
=cut


die 'bad arguments' if (@ARGV != 1);
my $n = shift @ARGV;
die 'not natural' if ($n < 1 or ($n - int($n) != 0));

sub fib_n($) {
	my $n = shift;
	my $x = 1;
	my $y = 0;
	for (1..$n - 1)
	{
		$x += $y;
		$y = $x - $y;
	}
	return $x;
}

say fib_n($n);