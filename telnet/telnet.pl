#!/usr/bin/perl
use 5.016;
use warnings;
use DDP;
use Socket ":all";
use IO::Select;
use AE;

my ($host, $port) = @ARGV;

my ($s, $resp);
eval {
	socket $s, AF_INET, SOCK_STREAM, IPPROTO_TCP
		or die;
	my $addr = gethostbyname $host or die;

	my $ip = inet_ntoa $addr or die;
	say "Trying $ip...";
	my $sa = sockaddr_in($port, $addr) or die;
	connect($s, $sa) or die ;
	1;
} or die "telnet: Unable to connect to remote host:";


$s->autoflush(1);

$SIG{INT} = sub { print $s chr(3) };

say "Connected to $host.";

if (my $pid = fork()){
	while (defined($resp = <$s>)) {
		print $resp;
	}
	kill "INT", $pid;
	say "Connection closed by foreign host";
	exit;
}
elsif (defined $pid) {
	while (<STDIN>) {
		print $s $_;
	}
	exit(0);
}
else {
	die "can't fork!";
}