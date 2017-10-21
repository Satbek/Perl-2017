#!/usr/bin/perl
use 5.016;
use DDP;
use warnings;
use Getopt::Long;
no warnings "uninitialized";
use List::Util qw(uniqnum);
=task
принимает STDIN, разбивает по разделителю (TAB) на
колонки, выводит запрошенные
Поддержать флаги:
-f  - "fields" - выбрать поля (колонки)
-d  - "delimiter" - использовать другой разделитель
-s  - "separated" - только строки с разделителем
См.  man cut  (linux) linux.die.net/man/1/cut
=cut

my (@f, $d, $s);
$d = "\t";
GetOptions('f=s' => \&f_handler, 'd=s' => \&d_handler, 's' => \$s) or die("Error in command line arguments\n");
die "cut: you must specify a list of bytes, characters, or field" unless @f;

sub f_handler {
	my ($opt_name, $opt_value) = @_;
	die "cut: option requires an argument -- 'f'\n" unless $opt_value;
	die "cut: fields are numbered from 1\n" if $opt_value =~ /,0|0,|-0|0-/;
	my (@f1, @f2);
	push @f1, $opt_value =~ /^\s*(\d+)\s*$/ if $opt_value =~ /^\s*\d+\s*$/;
	push @f1, $opt_value =~ /(\d+),/g if $opt_value =~ /(\d+),/;
	push @f1, $opt_value =~ /,(\d+)/g if $opt_value =~ /,(\d+)/;
	push @f2, $opt_value =~ /(\d+)-(\d+)/ if $opt_value =~ /(\d+)-(\d+)/;
	@f2 = ($f2[0] .. $f2[1]);
	die "cut: invalid decreasing range\n" unless @f2;
	push @f,  uniqnum (grep {$_} @f1, grep {$_} @f2);
	@f = sort {$a <=> $b} @f;
	die "cut: invalid field value $opt_value\n" unless (@f);
}


sub d_handler {
	my ($opt_name, $opt_value) = @_;
	die "cut: the delimiter must be a single character\n" unless length $opt_value == 1;
	$d = $opt_value;
}
=df
1	2	32
4	3	4
7	2	1
=cut


my @data = <>;
@data = grep {/$d/} @data if $s;

my @rows;
my %one_line;

for my $line (@data) {
	my @buf;
	chomp($line);
	if ($line =~ /^[^$d]+$/) {
		$one_line{@rows} = $line;
		push @buf, $line;
	}
	else {
		push @buf, /([^$d]+)$d?/g for $line;
	}
	push @rows, [@buf];
}

for my $i(0..$#rows) {
	my $res = "";
	for my $j(@f) {
		$res = $res . $rows[$i][$j - 1];
		$res = $res . $d x ($j ne $f[-1]);
	}
	$res = $one_line{$i} if exists $one_line{$i};
	print $res."\n";
}