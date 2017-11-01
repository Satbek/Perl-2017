package Local::Reducer::Sum;
use parent "Local::Reducer";
use 5.016;
use warnings;
use DDP;
use Scalar::Util "looks_like_number";

sub new {
	my ($self, %args) = @_;
	$self = $self->SUPER::new(%args);
	$self->{field} = $args{field};
	return bless $self; 
}

sub reduce {
	my $self = shift;
	my $row = $self->{source}->next;
	if ($row) {
		if ( $row = $self->{row_class}->new(str => $row) ) {
			if ( looks_like_number($row->get($self->{field}, 0)) ) {
				$self->{reduced} += $row->get($self->{field}, 0);
			}
		}
		return "success";
	}
	else {
		return undef;
	}
}

1;