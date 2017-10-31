package JSON;
use 5.016;
use warnings;
use JSON::XS qw/decode_json/;
use DDP;
sub new {
	my ($self, $str) = @_;
	my $data = eval{ decode_json $str };
	return $data ? bless $data : $data;
}

sub get {
	my ($self, $name, $default) = @_;
	{
		no warnings 'uninitialized';
		return exists $self->{$name} ? $self->{$name} : $self->{$default};
	}
}
1;