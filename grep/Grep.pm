package Grep;
use 5.016;
use DDP;
use warnings;
use Getopt::Long;

sub ABC_get_num($) {
	my $opt_name = shift;
	die "grep: $opt_name: invalid context length argumen" unless $opt_name =~ /^\s*(?<value>\d+)\s*$/;
	return $+{value};
}

sub check_ARGV($) {
	my @arr = @{shift()};
	die	"Usage: grep [OPTION]... PATTERN [FILE]..." unless @arr;

	if (@arr != 1) {
		my $die_ans = "";
		shift @arr;
		$die_ans = $die_ans."grep: $_: No such file or directory\n" for @arr;
		die "$die_ans";
	}
}

sub process_i_re($) {
	my $pattern = shift;
	return qr/$pattern/i;
}

sub process_v($) {
	my $pattern = shift;
	$pattern = "^(?:(?!$pattern).)*\$";
	#https://stackoverflow.com/questions/23403494/perl-matching-string-not-containing-pattern
	return $pattern;
}

sub process_F($) {
	my $pattern = shift;
	return quotemeta($pattern);
}

sub create_output {
	my ($A, $B, $C,  $c, $n, $re, $arr) = @_; 
	my @data = @{$arr};
	my %num_data;
	my $before = $B ? $B : $C;
	my $after = $A ? $A : $C;
	@num_data{1..$#data + 1} = @data;
	my %num_filtered_data = grep {$_} map { $_ => $n ? ":".$num_data{$_} : $num_data{$_}
										if $num_data{$_} =~ $re} sort keys %num_data;
	if ($c) {
		return scalar keys %num_filtered_data;
	}
	if ($after) {
		for my $num(sort {$a <=> $b} keys %num_filtered_data) {
			for my $i(1..$after) {
				$num_filtered_data{$num + $i} = $n ? "-".$data[$num + $i - 1] : $data[$num + $i - 1]
					if ( !exists $num_filtered_data{$num + $i} and $num + $i - 1 < @data);
			}
		}
	}
	if ($before) {
		for my $num(sort {$a <=> $b} keys %num_filtered_data) {
			for my $i(reverse(1..$before)) {
				$num_filtered_data{$num - $i} = $n ? "-".$data[$num - $i - 1] : $data[$num - $i - 1]
					if ( !exists $num_filtered_data{$num - $i} and $num - $i - 1 >= 0);
			}
		}
	}
	my $res = "";
	my @sorted = sort {$a <=> $b} keys %num_filtered_data;
	for (sort {$a <=> $b} keys %num_filtered_data) {
		$res = $n ? $res.$_."$num_filtered_data{$_}\n" : $res."$num_filtered_data{$_}\n";
		$res = $res."--\n"
			if (!exists $num_filtered_data{$_ + 1} and $_ != $sorted[-1]);
	}
	return $res;
}

1;