#!/usr/bin/perl
use 5.016;
use warnings;
use DDP;
use Sys::Hostname;
$|++;
say "hello, it's my shell!";
my $host = hostname;
my $prefix = "$ENV{USER}\@$host:~$ENV{PWD}\$ ";
print $prefix;
while(<>) {
	chomp;
	my @commands = split /\|/;
	my ($read, $write);
	my @buffer;
	for (@commands) {
		pipe my ($parent_rdr, $child_wdr);
		pipe my ($child_rdr, $parent_wdr);
		$child_wdr->autoflush(1);
		$parent_wdr->autoflush(1);
		my $pid;
		if (!($pid = fork)) {
			close $child_rdr;
			close $child_wdr;
			open (STDOUT, ">&=".fileno($parent_wdr)) or die $!;
			open (STDIN, "<&=".fileno($parent_rdr)) or die $! ;
			s/^\s*(.*)\s*$/$1/;
			exec "/bin/$_" or die $!;
			close $parent_rdr;
			close $parent_wdr;
			exit;
		}
		elsif ($pid < 0) {
			warn "error";
			next;
		}
		else {
			close $parent_rdr;
			close $parent_wdr;
			for (@buffer) {
				print $child_wdr $_;
			}
			close($child_wdr);
			@buffer = ();
			while (<$child_rdr>) {
				push @buffer, $_;
			}
			#say "process " . wait() . " killed";
			close($child_rdr);
		}
	}
	for (@buffer) {
		print $_;
	}
	print $prefix;
}