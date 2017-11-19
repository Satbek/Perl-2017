package Local::View;
use 5.016;
use warnings;
use DDP;
use JSON::XS;
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
	return sub {
		my $result = $sub->(@_);
		unless (ref $result eq "ARRAY" or ref $result eq "HASH") {
			$result = [$result];
		}
		return $result;
	};
}

sub set_data_type {
	no warnings 'redefine';
	shift;
	my $decorator = shift;
	*get_data = eval "_$decorator \\&get_data" || die $!;
}

1;