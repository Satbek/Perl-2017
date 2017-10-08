#!/usr/bin/perl
use 5.016;
use warnings;
no warnings "uninitialized";
no warnings 'numeric';
use DDP;
use Getopt::Long;
use List::Util qw(uniqnum uniqstr);
my ($k, $n, $r, $u, $b_, $c, $h, $M);

GetOptions ('k=i' => \&k_handler, 'n' => \$n, 'r' => \$r, 'u' => \$u, 'b' => \$b_,
			'c' => \$c, 'M' => \$M, 'h' => \$h) or die("Error in command line arguments\n");

die "can't set M and h together!" if defined $M && defined $h;

die "can't set h and n together!" if defined $n && defined $h; 

if ($h) {
	$n = 1;#for default sort
}


sub k_handler{
	my ($opt_name, $opt_value) = @_;
	$k = $opt_value;
	die "only natural k" unless $k > 0;
}
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

$compare{compare_str_def} = sub($$) {($a, $b) = @_; fc($a) cmp fc($b)};
$compare{compare_nums_def} = sub($$) {($a, $b) = @_; $a <=> $b};
$compare{compare_str_rev} = sub($$) {($a, $b) = @_; fc($b) cmp fc($a)};
$compare{compare_nums_rev} = sub($$) {($a, $b) = @_; $b <=> $a};

$compare{compare_str_def_k} = sub($$) {($a, $b) = @_; fc($columns{$a}) cmp fc($columns{$b})};
$compare{compare_nums_def_k} = sub($$) {($a, $b) = @_; $columns{$a} <=> $columns{$b}};
$compare{compare_str_rev_k} = sub($$) {($a, $b) = @_; fc($columns{$a}) cmp fc($columns{$b})};
$compare{compare_nums_rev_k} = sub($$) {($a, $b) = @_; $columns{$a} <=> $columns{$b}};

my @data = <>;
chomp $_ for @data;

if ($k) {
	for (@data) {
		my @buf = split ' ', $_;
		$columns{$_} = $buf[$k - 1];
	}
	# for (values %columns){
	# 	die "sort: invalid number at field start:!" if $_ eq undef;
	# }
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

#p %compare;
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


my $M_compare = sub($$) {
	($a, $b) = @_;
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

my $compM = $comp;
if ($M) {
	$compM = $M_compare;
}

#my $comp__ = $compM;


my %blocks = (
	'kB' => 1,
	'k' => 1,
	'K' => 1,
	'KiB' => 2,
	'MB' => 3,
	'M' => 3,
	'MiB' => 4,
	'GB' => 5,
	'G' => 5,
	'GiB' => 6,
	'TB' => 7,
	'T' => 7,
	'TiB' => 8,
	'PB' => 9,
	'P' => 9,
	'PiB' => 10,
	'EB' => 11,
	'E' => 11,
	'EiB' => 12,
	'ZB' => 13,
	'Z' => 13,
	'ZiB' => 14,
	'YB' => 15,
	'Y' => 15,
	'YiB' => 16,
);

my $h_compare = sub($$) {
	($a, $b) = @_;
	my ($d_a, $sig_a, $d_b, $sig_b);
	for (keys %blocks) {
		if ($a =~ /(\d+)($_)/) {
			$d_a = $1; 
			$sig_a = $2;
		}
		if ($b =~ /(\d+)($_)/) {
			$d_b = $1;
			$sig_b = $2;
		}
	}
	if (defined $d_a && defined $sig_a && defined $d_b && defined $sig_b) {
		if ($r){
			if (($blocks{$sig_b} <=> $blocks{$sig_a}) != 0) {
				return $blocks{$sig_b} <=> $blocks{$sig_a};
			}
			else {
				return $d_b <=> $d_a;
			}
		}
		else {
			if (($blocks{$sig_a} <=> $blocks{$sig_b}) != 0){
				return $blocks{$sig_a} <=> $blocks{$sig_b};
			}
			else {
				return $d_a <=> $d_b;
			}
		}
	}
	elsif (defined $d_a && defined $sig_a && !defined $d_b && !defined $sig_b) {
		if ($r) {
			return -1;
		}
		else {
			return 1;
		}
	}
	elsif (!defined $d_a && !defined $sig_a && defined $d_b && defined $sig_b) {
		if ($r) {
			return 1;
		}
		else {
			return -1;
		}
	}
	elsif (!defined $d_a && !defined $sig_a && !defined $d_b && !defined $sig_b) {
		return $compM->($a, $b);
	}
};

my $compMh = $compM;
if ($h) {
	$compMh = $h_compare;
}

my $b_compare = sub($$) {
	($a, $b) = @_;
	$a =~ /(.*?)\s*$/;
	my $first = $1;
	$b =~ /(.*?)\s*$/;
	my $second = $1;
	return $compMh->($first, $second);
};

my $compare;
$compare = $compMh;
if ($b_) {
	$compare = $b_compare;
}

if ($c) {
	for my $i(0..@data - 2) {
		my $sorted = $compare -> ($data[$i],$data[$i + 1]);
		my $pos = $i + 2;
		if ($sorted >= 0) {
			say "sort: -:$pos: disorder: $data[$i+1]";
			exit;
 		}
	}
}

my @result = sort $compare @data;
if ($u) {
	my @buf;
	for my $i(1..$#result + 1) {
		push @buf, $result[$i - 1] if $compare->($result[$i],$result[$i - 1]);
	}
	@result = @buf;
}
#p @result;
say join "\n", @result;