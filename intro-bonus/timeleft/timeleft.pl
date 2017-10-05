#!/usr/bin/env perl

use 5.016;
use warnings;
use Time::Local 'timelocal';
=f
## Посчитать сколько осталось секунд до конца часа, дня, недели

* Программа не принимает ничего на вход
* Печатает на выход 3 числа, сколько осталось секунд до конца часа, дня и недели
* `perldoc -f time`
* `perldoc -f localtime`
=cut
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);


sub hour_end {
	return 60*60 - $min*60 - $sec;
}

sub day_end {
	return 24*60*60 - $hour*60*60 - $min*60 - $sec;
}

sub week_end {
	return 0 if $wday == 0; #итак воскресенье
	return (6 - $wday) * 24*60*60 + 24*60*60 - $hour*60*60 - $min*60 - $sec;
}

say "hour end: ".hour_end." day end:".day_end." week end: ".week_end;