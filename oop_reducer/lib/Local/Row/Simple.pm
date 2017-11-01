package Local::Row::Simple;
use 5.016;
use warnings;
use DDP;
sub new {
	my ($self, %data) = @_;
	my $str = $data{str};
	my @pairs;
	return {} unless $str;
	push @pairs, $str =~ /^([^,]*)$/ if $str =~ /^([^,]*)$/;
	push @pairs, $str =~ /([^,]*),/ if $str =~ /([^,]*),/;
	push @pairs, $str =~ /,([^,]*)/g if $str =~ /,([^,]*)/;
	my %res = map {/^(?<key>[^:,]*):(?<value>[^,:]*)$/ ? ( $+{key} => $+{value} ) : return undef } @pairs;
	return bless \%res; 
}

sub get {
	my ($self, $name, $default) = @_;
	{
		no warnings 'uninitialized';
		return exists $self->{$name} ? $self->{$name} : $self->{$default};
	}
}


1;