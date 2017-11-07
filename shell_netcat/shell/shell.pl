#!/usr/bin/perl
use 5.016;
use warnings;
use DDP;
use Sys::Hostname;
use Cwd qw(cwd getcwd);;
#cd/pwd/echo/kill/ps
$|++;
say "hello, it's my shell!";

sub get_prefix {
	my $host = hostname;
	my $current_dir = getcwd();
	$current_dir =~ s/^$ENV{HOME}//;
	return "$ENV{USER}\@$host:~$current_dir\$ ";
}

sub process_command_in_child {
	my $command = shift;
	if ($command =~ /^echo\s*(?:(?<=\s)(?<arg>[^\s]+))?$/) {
		my $arg = $+{arg};
		$arg ||= "";
		if ($arg =~ /^\$/) {	
			my $env_arg = substr $arg, 1;
			$arg = $ENV{$env_arg} if exists $ENV{$env_arg};
		}
		say $arg;
	}
	elsif ($command =~ /^\s*pwd\s*$/) {
		say cwd;
	}
	elsif ($command =~ /^\s*kill\s+(\d+)\s*$/){
		kill 'KILL', $1;
	}
	elsif ($command =~ /^\s*ps\s*$/) {
		# By default, ps selects all processes with the same effective user ID (euid=EUID) 
		# as the current user and associated with the same
  #      terminal as the invoker.  It displays the process ID (pid=PID), the terminal associated
  #       with the process (tname=TTY), the cumulated
  #      CPU time in [DD-]hh:mm:ss format (time=TIME), and the executable name (ucmd=CMD).  Output is unsorted by default.
		my $my_tty = readlink("/proc/$$/fd/0");
		my $euid = $>;
	}
	else {
		no warnings;
		for my $path (split ":", $ENV{PATH}) {
			eval { exec "$path/$command" };
		}
	}
}

sub change_dir {
	my $path = shift;
	if ($path) {
		chdir($path);
	}
	else {
		chdir;
	};
}

print get_prefix;
while(<>) {
	chomp;
	my @commands = split /\|/;
	my ($read, $write);
	my @buffer;
	for my $command (@commands) {
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
			$command =~ s/^\s*(.*)\s*$/$1/;
			process_command_in_child($command);
			close $parent_rdr;
			close $parent_wdr;
			exit;
		}
		elsif (!defined $pid) {
			warn "error";
			next;
		}
		else {
			close $parent_rdr;
			close $parent_wdr;
			if ($command =~ /^cd\s*(?:(?<=\s)(?<path>[^\s]+))?$/) {
				change_dir($+{path});
			}
			for (@buffer) {
				print $child_wdr $_;
			}
			close($child_wdr);
			@buffer = ();
			while (<$child_rdr>) {
				push @buffer, $_;
			}
			close($child_rdr);
			wait; #kill zombie
		}
	}
	for (@buffer) {
		print $_;
	}

	print get_prefix;
}