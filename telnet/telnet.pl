#!/usr/bin/perl
use 5.016;
use warnings;
use DDP;
use Socket ":all";
use IO::Select;
use AE;
my ($host, $port) = @ARGV;

my $s;
eval {
	socket $s, AF_INET, SOCK_STREAM, IPPROTO_TCP
		or die;
	my $addr = gethostbyname $host or die;

	my $ip = inet_ntoa $addr or die;
	say "Trying $ip...";
	my $sa = sockaddr_in($port, $addr) or die;
	connect($s, $sa) or die ;
} or die "telnet: Unable to connect to remote host:";


$s->autoflush(1);


say "Connected to $host";

my $cv = AE::cv;
my ($r_c,$w_s, $r_s);

$r_c = AE::io \*STDIN, 0, sub {
	my $line = <STDIN>;
	$w_s = AE::io $s, 1, sub {
		syswrite ($s, $line);
		$r_s = AE::io $s, 0, sub {
			local $/;
			my $ans = <$s>;
			if ($ans) {
				print $ans;
			}
			else {
				undef $r_c;
				$cv->send;
				print "Connection closed by foreign host\n";
			}
			undef $r_s;
		};
		undef $w_s;
	};
};


$cv->recv;
exit;