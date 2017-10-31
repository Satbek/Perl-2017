package Array;
use 5.016;
use warnings;
use DDP;
sub new {
	shift;
	my %data = @_;
	return bless \%data;
}

sub next {
	my $self = shift;
	return @{$self->{array}} ? shift @{$self->{array}} : undef;
}

1;