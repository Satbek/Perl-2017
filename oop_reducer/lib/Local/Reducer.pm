package Local::Reducer;
use 5.016;
use strict;
use warnings;
use DDP;
=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new {
	my ($self, %args) = @_;
	my %data;
	$data{source} = $args{source};
	$data{row_class} = $args{row_class};
	$data{reduced} = $args{initial_value};
	return bless \%data;
}


sub reduce {
	my $self = shift;
	my $row = $self->{source}->next; 
	if ($row) {
		#...
	}
	else { return undef }
}

sub reduce_n {
	my ($self, $n) = @_;
	for (1..$n) {
		$self->reduce();
	}
	return $self->reduced;
}

sub reduce_all {
	my $self = shift;
	while ($self->reduce()) {}
	return $self->reduced;
}

sub reduced {
	my $self = shift;
	return $self->{reduced};
}




1;
