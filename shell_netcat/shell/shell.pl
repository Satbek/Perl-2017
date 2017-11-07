#!/usr/bin/perl
use 5.016;
use warnings;
use DDP;
use Sys::Hostname;
use List::Util qw/maxstr max/;
#cd/pwd/echo/kill/ps
$|++;

say "hello, it's my shell!";

sub get_prefix {
	my $host = hostname;
	my $current_dir = readlink "/proc/$$/cwd";
	$current_dir =~ s/^$ENV{HOME}/~/;
	return "$ENV{USER}\@$host:$current_dir\$ ";
}

sub get_proc_info {
	my $pid = shift;
	open (my $fd, '<', "/proc/$pid/stat") or die $!;
	my $stat = <$fd>;
	my @stat_info = split ' ', $stat;
	my %proc_info;
	$stat_info[1] =~ s/\((.+)\)/$1/;
	$proc_info{name} = $stat_info[1];
	$proc_info{pid} = $stat_info[0];
	$proc_info{ppid} = $stat_info[3];
	return \%proc_info;
}


sub ps {
	opendir(my $dh, '/proc') or die $!;
	my @processes;
	while(my $proc = readdir $dh){
		if ($proc =~ /^\d+$/) {
			push @processes, get_proc_info($proc);
		}
	}
	p @processes;
	my $max_name_length = max map { length $_->{name} } @processes;
	$max_name_length = $max_name_length > length "CMD" ? $max_name_length : length "CMD";
	my $max_pid_length = max map { length $_->{pid} } @processes;
	$max_pid_length = $max_pid_length > length "CMD" ? $max_pid_length : length "PID";
	my $max_ppid_length = max map { length $_->{ppid} } @processes;
	$max_ppid_length = $max_ppid_length > length "CMD" ? $max_ppid_length : length "PID";
	print " " x ($max_pid_length - length("PID"))."PID ";
	print " " x ($max_pid_length - length("PPID"))."PPID ";
	print " " x ($max_name_length -length("CMD"))."CMD\n";
	for (@processes) {
		print " " x ($max_pid_length - length($_->{pid}))."$_->{pid} ";
		print " " x ($max_pid_length - length($_->{ppid}))."$_->{ppid} ";
		print " " x ($max_name_length -length($_->{name}))."$_->{name}\n";
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

sub process_build_in_command {
	my $command = shift;
	my $buffer = shift;
	if ($command =~ /^echo\s*(?:(?<=\s)(?<arg>[^\s]+))?$/) {
		my $arg = $+{arg};
		$arg ||= "";
		if ($arg =~ /^\$/) {	
			my $env_arg = substr $arg, 1;
			$arg = $ENV{$env_arg} if exists $ENV{$env_arg};
		}
		push  @{$buffer}, $arg."\n";
		return 1;
	}
	elsif ($command =~ /^cd\s*(?:(?<=\s)(?<path>[^\s]+))?$/) {
		change_dir($+{path});
		return 1;
	}
	elsif ($command =~ /^\s*pwd\s*$/) {
		push @{$buffer}, readlink "/proc/$$/cwd","\n";
		return 1;
	}
	elsif ($command =~ /^\s*kill\s+(\d+)\s*$/){
		kill 'KILL', $1;
		return 1;
	}
	elsif ($command =~ /^\s*ps\s*$/) {
		ps;
		return 1;
	}
	return 0;
}

sub exec_command_in_child {
	my $command = shift;
	my $buffer = shift;
	pipe my ($parent_rdr, $child_wdr);
	pipe my ($child_rdr, $parent_wdr);
	$child_wdr->autoflush(1);
	$parent_wdr->autoflush(1);
	my $pid;
	if (!($pid = fork)) {
		close $child_rdr;
		close $child_wdr;
		open (STDOUT, ">&=".fileno($parent_wdr)) or die $!;
		open (STDIN, "<&=".fileno($parent_rdr)) or die $!;
		$command =~ s/^\s*(.*)\s*$/$1/;
		{
			no warnings;
			for my $path (split ":", $ENV{PATH}) {
				eval { exec "$path/$command" };
			}
			print "$command: command not found\n";
		}
		close $parent_rdr;
		close $parent_wdr;
		exit;
	}
	elsif (!defined $pid) {
		warn "error";
	}
	else {
		close $parent_rdr;
		close $parent_wdr;
		for (@{$buffer}) {
			print $child_wdr $_;
		}
		close($child_wdr);
		@{$buffer} = ();
		while (<$child_rdr>) {
			push @{$buffer}, $_;
		}
		close($child_rdr);
		wait; #kill zombie
	}
}

print get_prefix;
while(<>) {
	chomp;
	my @commands = split /\|/;
	my ($read, $write);
	my @buffer;
	for my $command (@commands) {
		exec_command_in_child($command, \@buffer) unless process_build_in_command($command, \@buffer);
	}
	for (@buffer) {
		print $_;
	}
	print get_prefix;
}