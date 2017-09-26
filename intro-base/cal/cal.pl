#!/usr/bin/perl
use 5.016;
use warnings;
# perldoc -f time
# perldoc -f localtime
# perldoc -f sprintf
use Time::Local 'timelocal'; # может помочь в вычислении time для заданного месяца
use DDP;
my $year = (localtime(time))[5];
$year += 1900;

my %months = (
	January => 31,
	March => 31,
	April => 30,
	May => 31,
	June => 30,
	July => 31,
	August => 31,
	September => 30,
	October => 31,
	November => 30,
	December => 31,
);

if ($year % 400 == 0 || $year % 4 == 0 && $year % 100 != 0 ) {
	$months{February} = 29;
}
else {
	$months{February} = 28;
}

my @abbr = qw(January February March April May June July August September October November December);

my @week_days = qw(Mo Tu We Th Fr Sa Su);

my $second_line = join " ", @week_days;

my $month_len = length($second_line);

sub make_month_head($) {
	my $first_line = shift;
	my $offset = ($month_len - length($first_line))/2;
	my $off1 = "";
	$off1 = $off1." " for(1..$offset);
	my $offset2 = $month_len - length($first_line) - $offset;
	my $off2 = "";
	$off2 = $off2." " for(1..$offset2);
	return $off1.$first_line.$off2;
}

sub make_year_head($) {
	my $first_line = shift;
	my $offset = ($month_len*3 + 4 - length($first_line))/2;
	my $off1 = "";
	$off1 = $off1." " for(1..$offset);
	my $offset2 = $month_len - length($first_line) - $offset;
	my $off2 = "";
	$off2 = $off2." " for(1..$offset2);
	return $off1.$first_line.$off2;
}

sub make_month($$$) {
	my ($wday, $month, $year ) = @_;

	my @result;
	
	push @result , $second_line;
	
	my $first_week  = "";
	$first_week = $first_week."   " for(1..$wday);
	for my $i(1..(7 - $wday)) {
		$first_week = $first_week." $i "
	}
	chop($first_week);
	push @result, $first_week;

	my $days_in_month = $months{$abbr[$month]};
	my $start = 8 - $wday;

	while ($start <= $days_in_month) {
		my $week = "";
		for (1..7) {
			last if ($start > $days_in_month);
			if ($start < 10) {
				$week = $week.sprintf(" %s ",$start);
			}
			else {
				$week = $week.sprintf("%s ",$start);
			}
			$start++;
		}
		chop($week);
		$week = $week." " until (length($week) == length($second_line));
		push @result, $week;
	}
	return \@result;
}

sub get_wday_by_mon($$) {
	my ($month, $year) = @_;
	my $time = timelocal(0,0,0,1,$month,$year - 1900);
	my $wday = (localtime($time))[6];
	$wday = ($wday + 6) % 7;
	return $wday;
}

if (@ARGV == 1) {
	my ($month) = @ARGV;
	die "incorrect input !" if ($month < 1 or $month > 12 or $month != int($month));
	# нам передали номер месяца. проверяем параметр и
	# печатаем календарь на этот месяц
	my $wday = get_wday_by_mon($month - 1, $year);
	my $result = make_month($wday, $month - 1, $year);
	$result = join "\n", @{$result};
	say make_month_head("$abbr[$month - 1] $year")."\n".$result;
}
elsif (not @ARGV) {
	# печатаем календарь на год
	my $empty_str = join "" ,map {$_ = " "} split(//,$second_line);
	my @months;
	for my $m(1..12) {
		my $wday = get_wday_by_mon($m - 1, $year);
		my @buf = @{make_month($wday, $m - 1, $year)};
		unshift @buf, make_month_head("$abbr[$m - 1]");
		push @buf, $empty_str until(scalar @buf == 8);
		push @months, \@buf;
	}
	say make_year_head("$year");

	for my $i(0..3) {
		for my $j(0..7) { printf("%s  %s  %s\n", $months[3*$i]->[$j], $months[3*$i + 1]->[$j], $months[3*$i + 2]->[$j])};
	}
}
else {
	# неверное количество аргументов
	die "incorrect input !";
}