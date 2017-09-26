#!/usr/bin/env perl
use 5.016;
use warnings;
use DDP;
=task
## Распечатать словами число

* В качестве аргумента программа принимает натуральное число
* На выход печатает словесное представление этого числа (на русском языке)
* Программа должна проверять, что число натуральное. Если число не натуральное - печатаем ошибку.
* Поддержать числа до миллиарда включительно

$ perl lingnum.pl 1
один
$ perl lingnum.pl 10000
десять тысяч
$ perl lingnum.pl 1003102
один миллион три тысячи сто два
=cut
die "only one argument!" unless @ARGV == 1;
my $n = shift;

die "not natural" if $n != int($n) or $n < 1;
die "too big number" if $n > 1000000000;

if ($n == 1000000000) {
	say "миллиард";
	exit;
}

my @fisrst = ("", qw/один два три четыре пять шесть семь восемь девять/);

my @elvn_9teen = ("", qw/одиннадцать двенадцать тринадцать четырнадцать 
			пятнадцать шестнадцать семнадцать восемнадцать девятнадцать/);

my @tens = ("", qw/десять двадцать тридцать сорок пятьдесят шестьдесят 
			семьдесят восемьдесят девяносто/);

my @hundreds = ("", qw/сто двести триста четыреста пятьсот шестьсот 
				семьсот восемьсот девятьсот/);

my %mil_end = (
	"один" => "миллион",
	"два" => "миллиона",
	"три" => "миллиона",
	"четыре" => "миллиона",
);

my %hun_end = (
	"одна" => "тысяча",
	"две" => "тысячи",
	"три" => "тысячи",
	"четыре" => "тысячи",
);

sub get_discharges($) {
	my $n = shift;
	my @n = split "", $n;
	unshift @n, 0 until @n == 9;
	my $mil = (join '', @n[0..2])+0;
	my $hun = (join '', @n[3..5])+0;
	my $dig = (join '', @n[6..8])+0;
	return $mil, $hun, $dig;
}

sub calc_discharge ($) {
	my $n = shift;
	return [] unless $n;
	my @n = split "", $n; 
	unshift @n, 0 until @n == 3;
	my @ans;

	my $d3 = $n[0];
	my $d2 = $n[1];
	my $d1 = $n[2];
	push @ans, $hundreds[$d3];

	if ($d2 > 1) {
		push @ans, $tens[$d2];
	}
	elsif ($d2 == 1) {
		if ($d1) {
			push @ans, $elvn_9teen[$d1];
			$d1 = 0;
		}
		else {
			push @ans, $tens[$d2]; 
		}
	}
	push @ans, $fisrst[$d1];
	@ans = grep {$_} @ans;
	return \@ans;
}

sub get_end ($$$) {
	my $num = shift;
	my $hash = shift;
	my $default = shift;
	return "" if @{$num} == 0;

	my $end = $num->[-1];
	if ($hash != 0 and exists $hash->{$end}) {
		$end = $hash->{$end};
	}
	else {
		$end = $default;
	}
	return $end;
}

my ($mil, $hun, $dig) = get_discharges($n);

my $answer = "";

if ($mil) {
	my @ans = @{calc_discharge($mil)};
	$answer = $answer.(join ' ', @ans)." ".get_end(\@ans, \%mil_end, "миллионов")." ";
}

if ($hun) {
	my @ans = @{calc_discharge($hun)};

	if (@ans) {
		if ($ans[-1] eq "один") {
			$ans[-1] = "одна";
		}

		if ($ans[-1] eq "два") {
			$ans[-1] = "две";
		}
	}
	$answer = $answer.(join ' ', @ans)." ".get_end(\@ans, \%hun_end, "тысяч")." " if @ans;
}

my @ans = @{calc_discharge($dig)};

$answer = $answer.(join ' ', @ans)." ".get_end(\@ans, 0, "");

say $answer;