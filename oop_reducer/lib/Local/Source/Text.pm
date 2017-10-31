package Text;
use 5.016;
use warnings;
use DDP;
sub new {
	shift;
	my %data = @_;
	$data{delimiter} = "\n" unless exists $data{delimiter};
	return bless \%data;
}

sub next {
	my $self = shift;
	my $delimiter = $self->{delimiter};
	return $self->{text} =~ s/(?<next>[^$delimiter]*)$delimiter|^(?<next>[^$delimiter]+)$// ? $+{next} : undef;
}

1;