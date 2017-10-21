#!/usr/bin/perl
use 5.016;
use warnings;
no warnings "uninitialized";
no warnings 'numeric';
use DDP;
use Getopt::Long;
my ($k, $n, $r, $u, $b_, $c, $h, $M);

GetOptions ('k=i' => \&k_handler, 'n' => \$n, 'r' => \$r, 'u' => \$u, 'b' => \$b_,
			'c' => \$c, 'M' => \$M, 'h' => \$h) or die("Error in command line arguments\n");

die "can't set M and h together!" if defined $M && defined $h;

die "can't set h and n together!" if defined $n && defined $h; 

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

my @data = <>;
chomp $_ for @data;


my $compare;

if ($n || $h) {
	$compare = sub($$) {($a, $b) = @_; $a <=> $b};
}
else {
	$compare = sub($$) {($a, $b) = @_; fc($a) cmp fc($b)};
}

sub decorator {
	my ($compare, $modify) = @_;
	return sub($$) {
		($a, $b) = @_;
		my @modify = @{$modify->($a,$b)};
		return $compare->($modify[0], $modify[1]);
	};
}

my %months = (
	'JAN' => '01',
	'FEB' => '02',
	'MAR' => '03',
	'APR' => '04',
	'MAY' => '05',
	'JUN' => '06',
	'JUL' => '07',
	'AUG' => '08',
	'SEP' => '09',
	'OCT' => '10',
	'NOV' => '11',
	'DEC' => '12',
);

if ($M) {
	my $modify = sub {
		my ($var1, $var2) = @_;
		my $arr;
		if (!exists $months{$var1} && !exists $months{$var2}) {
			return [$var1, $var2];
		}
		elsif (exists $months{$var1} && !exists $months{$var2}) {
			$months{$var2} = 0;
			return [$months{$var1}, $months{$var2} ];
		}
		elsif (!exists $months{$var1} && exists $months{$var2}) {
			$months{$var1} = 0;
			return [$months{$var1} , $months{$var2}];
		}
		elsif (exists $months{$var1} && exists $months{$var2}) {
			return [$months{$var1}, $months{$var2}];
		}
	}; 
	$compare = decorator($compare, $modify);
}

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

if ($h) {
	my $modify = sub {
		my ($var1, $var2) = @_;
		my ($d_1, $sig_1, $d_2, $sig_2);
		for (keys %blocks) {
			if ($a =~ /(\d+)($_)/) {
				$d_1 = $1; 
				$sig_1 = $2;
			}
			if ($b =~ /(\d+)($_)/) {
				$d_2 = $1;
				$sig_2 = $2;
			}
		}
		if (defined $d_1 && defined $sig_1 && defined $d_2 && defined $sig_2) {
			if ($blocks{$sig_1} != $blocks{$sig_2}) {
				return [$blocks{$sig_1}, $blocks{$sig_2}];
			}
			else {
				return [$d_1, $d_2];
			}
		}
		elsif (defined $d_1 && defined $sig_1 && !defined $d_2 && !defined $sig_2) {
			return [$blocks{$sig_1}, 0];
		}
		elsif (!defined $d_1 && !defined $sig_1 && defined $d_2 && defined $sig_2) {
			return [0, $blocks{$sig_2}];
		}
		elsif (!defined $d_1 && !defined $sig_1 && !defined $d_2 && !defined $sig_2) {
			return [$var1, $var2];
		}
	};
	$compare = decorator($compare, $modify);
}

if ($k) {
	for (@data) {
		my @buf = split ' ', $_;
		$columns{$_} = $buf[$k - 1];
	}
	my $modify = sub { my ($var1, $var2) = @_; return [$columns{$var1}, $columns{$var2}]; };
	$compare = decorator($compare, $modify);
}

if ($r) {
	my $modify = sub { my ($var1, $var2) = @_; return [$var2, $var1] };
	$compare = decorator($compare, $modify);
}

if ($b_) {
	my $modify = sub($$) {
		my ($var1, $var2) = @_;
		$a =~ /(.*?)\s*$/;
		my $first = $1;
		$b =~ /(.*?)\s*$/;
		my $second = $1;
		return [$first, $second];
	};
	$compare = decorator($compare, $modify);
}

if ($c) {
	for my $i(0..@data - 2) {
		my $sorted = $compare -> ($data[$i],$data[$i + 1]);
		my $pos = $i + 2;
		if ($sorted > 0) {
			say "sort: -:$pos: disorder: $data[$i+1]"; 		
			exit;
		}
	}
	exit;
}

my @result = sort $compare @data;
if ($u) {
	my @buf;
	for my $i(1..$#result + 1) {
		push @buf, $result[$i - 1] if $compare->($result[$i],$result[$i - 1]);
	}
	@result = @buf;
}

say join "\n", @result;