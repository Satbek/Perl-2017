package Local::Row::JSON;
use 5.016;
use warnings;
use JSON::XS qw/decode_json/;
use DDP;
sub new {
	my ($self, %args) = @_;
	my $str = $args{str};
	my $data = eval{ decode_json $str };
	return undef unless ref $data eq "HASH";
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