#!/usr/bin/perl
use 5.016;
use warnings;
use Coro;
use AnyEvent::ReadLine::Gnu;
use AnyEvent::Handle;
use DDP;
use AnyEvent::Socket;
use Socket;
$|++;
#connect vie AnyEvent::Socket
#связять AnyEvent::Socket и AnyEvent::Handle
#вся логика в AnyEvent::Gnu::Readline

#Coro::Channel
#Coro::Socket
#Coro::Readline сделай
#Coro::Handle

my ($host, $port) = @ARGV;

my $cv = AE::cv;

my $addr = gethostbyname $host or die;
my $ip = inet_ntoa $addr or die;
say "Trying $ip...";

my ($handle, $rl);


tcp_connect $host, $port, sub {
	my ($fh) = @_ or die "telnet: Unable to connect to remote host:";
	say "Connected to $host.";
	say "Escape character is '^]'.";
	$handle = AnyEvent::Handle->new(
		fh => $fh,
		on_error => sub {
			$_[0]->destroy;
			$cv->send("Connection closed by foreign host.\n");
		},
		on_eof => sub {
			$handle->destroy; # destroy handle
			$cv->send("Connection closed by foreign host.\n");
		},
		on_read => sub {
			$rl->print( $_[0]->rbuf );
			$_[0]->rbuf = "";
		},
	);
};

my $telnet = 0;
$rl = AnyEvent::ReadLine::Gnu->new(
	prompt => undef,
	on_line => sub {
		my $line = shift;
		if ( $line ne "^]" and !$telnet ) {
			$handle->push_write($line."\n");
		}
		elsif ( $line eq "^]" and !$telnet ) {
			$telnet = 1;
			$rl->hide;
			$rl->print("telnet");
			$rl->show;
		}
		elsif ( $telnet ) {
			if ( $line eq "quit" or $line eq "q" ) {
				$cv->send("Connection closed.\n");
			}
			elsif ( $line eq "" ) {
				$telnet = 0;
			}
			else {
				$rl->print("?Invalid command\n");
				$rl->hide;
				$rl->print("telnet");
				$rl->show;
			}
		}
	}
);


print $cv->recv;