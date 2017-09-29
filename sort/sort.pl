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
	die "incorrect k" if $k != int ($k);
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
	'JAN' => 1,
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
	my ($_a, $_b) = ($a, $b);
	if ($k) {
		($_a, $_b) = ($columns{$a}, $columns{$b});
	}
 	if (!exists $months{$_a} && !exists $months{$_b}) {
		return $comp->($a,$b);
	}
	elsif (exists $months{$_a} && !exists $months{$_b}) {
		if ($r) {
			return -1;
	 	}
	 	else {
	 		return 1;
	 	}
	}
	elsif (exists $months{$_b} && !exists $months{$_a}) {
		if ($r) {
			return 1;
		}
		else {
			return -1;
		}
	}
	elsif (exists $months{$_b} && exists $months{$_a}) {
		if ($r) {
			return $months{$_b} <=> $months{$_a};
		}
		else {
			return $months{$_a} <=> $months{$_b};
		}
 	}
};

my $comp_ = $comp;
if ($M) {
	$comp_ = $M_compare;
}

my $compare = $comp_;


my %blocks = (
	'kB' => [10,3],
	'k' => [10,3],
	'K' => [10,3],
	'KiB' => [2,10],
	'MB' => [10,6],
	'M' => [10,6],
	'MiB' => [2,20],
	'GB' => [10,9],
	'G' => [10,9],
	'GiB' => [2,30],
	'TB' => [10,12],
	'T' => [10,12],
	'TiB' => [2,40],
	'PB' => [10,15],
	'P' => [10,15],
	'PiB' => [2,50],
	'EB' => [10,18],
	'E' => [10,18],
	'EiB' => [2,60],
	'ZB' => [10,21],
	'Z' => [10,21],
	'ZiB' => [2,70],
	'YB' => [10,24],
	'Y' => [10,24],
	'YiB' => [2,80]
);

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