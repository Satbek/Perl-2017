package Local::View;
use 5.016;
use warnings;
use DDP;
use JSON::XS;
no warnings 'redefine';
sub new {
	return bless {};
}

sub _get_raw_data {
	my $Model = shift;
	return $Model->get_data;
}

sub get_data { shift; return _get_raw_data(@_); };

sub _to_json {
	my $sub = shift;
	return sub { encode_json($sub->(@_)) };
}

sub set_data_type {
	shift;
	my $decorator = shift;
	*get_data = eval "_$decorator \\&get_data" || die $!;
}

1;