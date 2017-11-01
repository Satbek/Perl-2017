package Local::Reducer::MaxDiff;
use parent "Local::Reducer";
use 5.016;
use warnings;
use DDP;
use Scalar::Util "looks_like_number";

sub new {
	my ($self, %args) = @_;
	$self = $self->SUPER::new(%args);
	$self->{top} = $args{top};
	$self->{bottom} = $args{bottom};
	return bless $self; 
}

sub reduce {
	my $self = shift;
	my $row = $self->{source}->next;
	if ($row) {
		$row = $self->{row_class}->new(str => $row);
		if ($row and looks_like_number( $row->get($self->{bottom}) ) and
			looks_like_number( $row->get($self->{top}) ) ) {
			my $diff = $row->get($self->{top}) - $row->get($self->{bottom});
			$self->{reduced} = $diff if $diff > $self->reduced;
		}
		return "success";
	}
	else {
		return undef;
	}
}

1;