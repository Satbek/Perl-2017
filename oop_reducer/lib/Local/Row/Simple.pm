package Simple;
use 5.016;
use warnings;
use DDP;
sub new {
	my ($self, $str) = @_;
	my @pairs;
	return undef unless $str;
	push @pairs, $str =~ /^([^,]*)$/ if $str =~ /^([^,]*)$/;
	push @pairs, $str =~ /([^,]*),/ if $str =~ /([^,]*),/;
	push @pairs, $str =~ /,([^,]*)/g if $str =~ /,([^,]*)/;
	my %data = map {/^(?<key>[^:,]*):(?<value>[^,:]*)$/ ? ( $+{key} => $+{value} ) : return undef } @pairs;
	return bless \%data; 
}

sub get {
	my ($self, $name, $default) = @_;
	{
		no warnings 'uninitialized';
		return exists $self->{$name} ? $self->{$name} : $self->{$default};
	}
}


1;