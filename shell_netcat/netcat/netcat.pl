#!/usr/bin/perl
use 5.016;
use warnings;
use DDP;
use IO::Socket;
$|++;

my ($ip, $port, $proto) = @ARGV;
unless (defined $proto) {
	$proto = "tcp";
}

my $socket = IO::Socket::INET->new(
	PeerHost => $ip,
	PeerPort => $port,
	Proto => $proto) or die "Can't connect to $ip $!";

my $pid;

if (!($pid = fork)) {
	while (<$socket>) {
		print $_;
	}
}
elsif (! defined $pid) {
	die "fork didn't work";
}
else {
	$SIG{CHLD} = sub {
		kill 'KILL', $pid;
		exit;
	};
	while (<STDIN>) {
		print $socket $_;
	}
}