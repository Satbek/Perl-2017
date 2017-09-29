#!/usr/bin/perl
use 5.016;
use warnings;
no warnings "uninitialized";
use DDP;
use Getopt::Long;
use List::Util qw(uniqnum uniqstr);
use Array::Compare;
my ($k, $n, $r, $u, $b_, $c, $h, $M);
GetOptions ('k=s' => \$k, 'n' => \$n, 'r' => \$r, 'u' => \$u, 'b' => \$b_,
			'c' => \$c, 'M' => \$M, 'h' => \$h);

=task
Основное
Поддержать ключи
-k — указание колонки для сортировки
-n — сортировать по числовому значению
-r — сортировать в обратном порядке
-u — не выводить повторяющиеся строки
Дополнительное

Поддержать ключи
-M — сортировать по названию месяца
-b — игнорировать хвостовые пробелы.
-c — проверять отсортированы ли данные
-h — сортировать по числовому значению с учётом суффиксов
=cut

die "incorrect k" if $k != int ($k);

my %compare;
my %columns;

$compare{compare_str_def} = sub {$a cmp $b};
$compare{compare_nums_def} = sub {$a <=> $b};
$compare{compare_str_rev} = sub {$b cmp $a};
$compare{compare_nums_rev} = sub {$b <=> $a};

$compare{compare_str_def_k} = sub {$columns{$a} cmp $columns{$b}};
$compare{compare_nums_def_k} = sub {$columns{$a} <=> $columns{$b}};
$compare{compare_str_rev_k} = sub {$columns{$a} cmp $columns{$b}};
$compare{compare_nums_rev_k} = sub {$columns{$a} <=> $columns{$b}};

my @data;
while (my $line = <STDIN>) {
	chomp($line);
	push @data, $line;
}


if ($k) {
	for (@data) {
		my @buf = split ' ', $_;
		$columns{$_} = $buf[$k - 1];
	}
	for (values %columns){
		die "sort: invalid number at field start:!" if $_ eq undef;
	}
	delete $compare{compare_nums_rev};
	delete $compare{compare_str_rev};
	delete $compare{compare_nums_def};
	delete $compare{compare_str_def};
}
else {
	delete $compare{compare_str_def_k};
	delete $compare{compare_nums_def_k};
	delete $compare{compare_str_rev_k};
	delete $compare{compare_nums_rev_k};
}

if ($n) {
	delete $compare{compare_str_def};
	delete $compare{compare_str_rev};
	delete $compare{compare_str_def_k};
	delete $compare{compare_str_rev_k};
}
else {
	delete $compare{compare_nums_def};
	delete $compare{compare_nums_rev};
	delete $compare{compare_nums_def_k};
	delete $compare{compare_nums_rev_k};
}

if ($r) {
	delete $compare{compare_str_def};
	delete $compare{compare_nums_def};
	delete $compare{compare_str_def_k};
	delete $compare{compare_nums_def_k};
}
else {
	delete $compare{compare_str_rev};
	delete $compare{compare_nums_rev};
	delete $compare{compare_str_rev_k};
	delete $compare{compare_nums_rev_k};
}

if ($u) {
	if ($n) {
		@data = uniqnum @data;
	}
	else {
		@data = uniqstr @data;
	}
}

die "filters do not work!" if keys %compare != 1;

my $comp = (values %compare)[0];

my %months = (
	'JUN' => 1,
	'FEB' => 2,
	'MAR' => 3,
	'APR' => 4,
	'MAY' => 5,
	'JUN' => 6,
	'JUL' => 7,
	'AUG' => 8,
	'SEP' => 9,
	'OCT' => 10,
	'NOV' => 11,
	'DEC' => 12
);


my $M_compare = sub {
 	if (!exists $months{$a} && !exists $months{$b}) {
		return $comp;
	}
	elsif (exists $months{$a} && !exists $months{$b}) {
		if ($r) {
			return -1;
	 	}
	 	else {
	 		return 1;
	 	}
	}
	elsif (exists $months{$b} && !exists $months{$a}) {
		if ($r) {
			return 1;
		}
		else {
			return -1;
		}
	}
	elsif (exists $months{$b} && exists $months{$a}) {
		return $months{$a} <=> $months{$b};
 	}
};

if ($M) {
	$comp = $M_compare;
}

my $compare = $comp;

my $cmp = Array::Compare->new;
if ($c) {
	for my $i(0..@data - 2) {
		my @sorted = sort $compare ($data[$i],$data[$i + 1]);
		my @buf =($data[$i],$data[$i + 1]);
		my $pos = $i + 2;
		unless ($cmp->compare(\@buf  ,\@sorted)) {
			say "sort: -:$pos: disorder: $data[$i+1]";
			exit;
 		}
	}
}

my @result = sort $compare @data;
say join "\n", @result;