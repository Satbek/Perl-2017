#!/usr/bin/perl
use 5.016;
use warnings;
use DDP;
use Sys::Hostname;
use List::Util qw/any max/;
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
	open (my $fd, '<', "/proc/$pid/status") or die $!;
	my @stat_info = <$fd>;
	my %proc_info;
	for (@stat_info) {
		if (/^Name:\s+(?<name>.+)$/) {
			#$_ =~ s/^\((.*)\)$/$1/;
			$proc_info{name} = $+{name};
		}
		if (/^Pid:\s+(?<pid>\d+)$/) {
			$proc_info{pid} = $+{pid};
		}
		if (/^PPid:\s+(?<ppid>\d+)$/) {
			$proc_info{ppid} = $+{ppid};
		}
	}
	return \%proc_info;
}

sub ps {
	opendir(my $dh, '/proc') or die $!;
	my @processes;
#	get_proc_info($$);
	while(my $proc = readdir $dh){
		if ($proc =~ /^\d+$/) {
			push @processes, get_proc_info($proc);
		}
	}
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

my @build_in_commands = qw/echo pwd kill ps cd/;

sub is_build_in_command {
	my $command = shift;
	$command =~ /^\s*(\w+)/;
	my $command_name = $1;
	no warnings 'uninitialized';
	return any { $_ eq $command_name } @build_in_commands;
}

sub process_build_in_command {
	my $command = shift;
	my $buffer = shift;
	if ($command =~ /^echo\s*(?:(?<=\s)(?<arg>[^\s].*))?$/) {
		my $arg = $+{arg};
		$arg ||= "";
		my @env_vars;
		push @env_vars, $arg =~ /\$(\w+)/g;
		for (@env_vars) {
			$arg =~ s/\$$_/$ENV{$_}/ if exists $ENV{$_};
		}
		push  @{$buffer}, $arg."\n";
	}
	elsif ($command =~ /^cd\s*(?:(?<=\s)(?<path>[^\s]+))?$/) {
		change_dir($+{path});

	}
	elsif ($command =~ /^\s*pwd\s*$/) {
		push @{$buffer}, readlink "/proc/$$/cwd","\n";

	}
	elsif ($command =~ /\s*kill(?:\s+(?<arg>\w+|-\d+))?\s+(?<pid>\d+)/){
		my $sig = $+{arg} ? $+{arg} : "KILL";
		kill $sig, $+{pid}; 
	}
	elsif ($command =~ /^\s*ps\s*$/) {
		ps;
	}
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
		$command =~ /^(\w+)/;
		my $command_name = $1;
		for my $path (split ":", $ENV{PATH}) {
			exec "$path/$command" if -x "$path/$command_name";
		}
		say "command not found: $command";
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
		is_build_in_command($command) ? process_build_in_command($command, \@buffer)
									:	exec_command_in_child($command, \@buffer);
	}
	for (@buffer) {
		print $_;
	}
	print get_prefix;
}