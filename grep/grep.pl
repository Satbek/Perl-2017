#!/usr/bin/perl
use 5.016;
use DDP;
use warnings;
use Grep;
use Getopt::Long;
Getopt::Long::Configure ("bundling", "no_ignorecase");
Getopt::Long::Configure ("bundling_values");

=task
Поддержать флаги:
-A  - "after" печатать +N строк после совпадения
-B  - "before" печатать +N строк до совпадения
-C  - "context" (A+B) печатать ±N строк вокруг совпадения
-c  - "count" (количество строк)
-i  - "ignore-case" (игнорировать регистр)
-v  - "invert" (вместо совпадения, исключать)
-F  - "fixed", точное совпадение со строкой, не паттерн
-n  - "line num", печатать номер строки

regex_flags:
-i

pattern_flags:
-v
-F

output_data_flags:
-A
-B
-C
-c
-n
=cut

#parse flags
my ($A, $B, $C, $c, $i, $v, $F, $n, $pattern);
GetOptions('A=s' => \$A, 'B=s' => \$B, 'C=s' => \$C,
			'c' => \$c, 'i' => \$i, 'v' => \$v, 'F' => \$F, 'n' => \$n) or die("Error in command line arguments\n");

$A = Grep::ABC_get_num($A) if defined $A;
$B = Grep::ABC_get_num($B) if defined $B;
$C = Grep::ABC_get_num($C) if defined $C;

Grep::check_ARGV(\@ARGV);

$pattern = $ARGV[0];

$pattern = Grep::process_F($pattern) if $F;
$pattern = Grep::process_v($pattern) if $v;

my $re = $i ? Grep::process_i_re($pattern) : qr/$pattern/;
my @data;
#@data = <> ????
while (<STDIN>) {
	chomp($_);
	push @data, $_;
}

my $res = Grep::create_output($A, $B, $C , $c, $n, $re ,\@data);
print $res;