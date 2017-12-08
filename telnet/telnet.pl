#!/usr/bin/perl
use 5.016;
use warnings;
use DDP;
use Socket ":all";
use AE;
use AnyEvent::ReadLine::Gnu;
use AnyEvent::Handle;

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

my ($read, $rl); 

my ($r, $w);
pipe ($r, $w);

$w->autoflush();

my $flag = 0;
$cv->begin;
$read = AE::io *STDIN, 0, sub {
	my $line = <STDIN>;
	if (length $line == 2 && ord($line) == 29 && !$flag) {
		$flag++;
		print $w $line;
		$cv->begin;
		$rl = AnyEvent::ReadLine::Gnu->new(in => $r, prompt => "telnet>", on_line => sub {
			my $stdin_line = shift;
			if (!$stdin_line) {
				$flag = 0;
				$cv->end;
			}
			elsif ($stdin_line eq "q" or $stdin_line eq "quit") {
				AnyEvent::ReadLine::Gnu->print ("Connection closed.\n");
				$cv->send;
			}
			else {
				AnyEvent::ReadLine::Gnu->print ("?Invalid command\n");
			}
		});
	}
	elsif($flag) {
		print $w $line;
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