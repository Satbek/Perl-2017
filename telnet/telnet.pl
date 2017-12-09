#!/usr/bin/perl
use 5.016;
use warnings;
use Coro;
use AnyEvent::ReadLine::Gnu;
use AnyEvent::Handle;
use DDP;
use DDP;
use Socket ":all";
$|++;

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

say "Connected to $host.";


say "Escape character is '^]'.";


my $cv = AE::cv;


my $who = "stdin";

my $term = Term::ReadLine->new('telnet');


my $read = AE::io *STDIN, 0, sub {
	my $line = <STDIN>;
	$who = "prompt" if (ord($line) == 29);
	if ($who eq "prompt") {
		while (defined (my $line = $term->readline('telnet>'))) {
			if (!$line) {
				$who = "stdin";
				last;
			}
			elsif ($line eq "q" or $line eq "quit") {
				print ("Connection closed.\n");
				exit;
			}
			else {
				print ("?Invalid command\n");
			}
		}
	}
	else {
		print $s $line;
	}
};


my $hdl; $hdl = AnyEvent::Handle->new(
	fh => $s,
	on_error => sub {
		my $hdl = shift;
		$hdl->destroy;
		$cv->send;
	},
	on_eof => sub {
		my $hdl = shift;
		$hdl->destroy;
		$cv->send;
		say "Connection closed by foreign host.";
	},
	on_read => sub {
		my $line = $_[0]->rbuf;
		print $line;
		$_[0]->rbuf = "";
	}
);

$cv->recv;