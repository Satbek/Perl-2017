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

while (<STDIN>) {
	select $socket;
	print $_;
	select STDOUT;
	my $ans;
	{
		local $/;
		$ans = <$socket>;
	}
	$ans ? print $ans : close ($socket); exit;
}