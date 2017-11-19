package Local::Controller;
use 5.016;
use warnings;
use DDP;
use Getopt::Long qw(GetOptionsFromArray);
use Local::Model;

sub new {
	shift;
	my @args = @_;
	return bless _parse_command_args(\@args);
}

sub _parse_command_args {
	my $args = shift;
	my %result;
	$result{command} = shift @{$args};
	my $ret;
	$ret = GetOptionsFromArray($args, "user=i" => \@{$result{args}});
	return \%result;
}

sub set_data {
	my $self = shift;
	my $Model = shift;
	$Model->set_data($self->{command}, @{$self->{args}});
}

1;