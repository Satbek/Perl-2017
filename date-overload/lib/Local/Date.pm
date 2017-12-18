package Local::Date;
use Moose;
use 5.016;
use Moose::Util::TypeConstraints;
use DDP;
use Time::Local;
use POSIX qw ( strftime );
use locale;
use POSIX qw ( locale_h );
use List::Util qw ( any );
use Carp qw(confess);
use Local::DateTypes;
use Scalar::Util qw(looks_like_number);
use Local::Date::Interval;
#задаем локаль, чтобы время выводились на английском

setlocale(LC_TIME, "en_US.UTF-8");

#day, month, year, hours, minutes, seconds - для компонентов даты

for my $name ( qw( seconds minutes hours year month day ) ) {
	my $builder = '_build_' . $name;
	has $name => (
		is => 'ro',
		isa => "$name",
		builder => $builder,
		lazy => 1,
		required => 1,
		predicate => "_has_$name",
		clearer => "_clear_$name",
	);
}

sub _build_seconds {
	my $self = shift;
	return (gmtime( $self->epoch ))[0];
}

sub _build_minutes {
	my $self = shift;
	say $self->epoch;
	return (gmtime( $self->epoch ))[1];
}

sub  _build_hours {
	my $self = shift;
	return (gmtime( $self->epoch ))[2];
}

sub _build_day {
	my $self = shift;
	return (gmtime( $self->epoch ))[3];
}

sub _build_month {
	my $self = shift;
	return (gmtime( $self->epoch ))[4] + 1;
}

sub _build_year {
	my $self = shift;
	return 1900 + (gmtime( $self->epoch ))[5];
}

#epoch - timestamp

subtype 'epoch'
	=> as 'Int'
	=> where { $_ >= 0 }
	=> message { "$_ can't be a seconds from 
				00:00:00 UTC, January 1, 1970" };

has 'epoch' => (
	is => 'ro',
	required => 1,
	builder => '_build_epoch',
	isa => 'epoch',
	lazy => 1,
	predicate => '_has_epoch',
	writer => '_set_epoch'
);

sub _build_epoch {
	my $self = shift;
	my $time = timegm( $self->seconds, $self->minutes, $self->hours, 
						$self->day, $self->month - 1, $self->year );
	return $time;
}


#format

subtype 'strftime_format'
	=> as 'Str'
	=> where { strftime ($_, gmtime) ne $_ }
	#если strftime хоть что-то заменит, то формат подходит
	=> message { "$_ is not strptime format" };

has 'format' => (
	is => 'rw',
	lazy => 1,
	isa => 'strftime_format',
	default => "%a %b %e %H:%M:%S %Y",
);


#operators

use overload
	'""'		=> \&_to_string,
	"<=>"		=> \&_compare,
	"cmp"		=> \&_compare_str,
	#'0+'		=> sub { shift-> epoch },
	'+'			=> \&_add,
	'-'			=> \&_subtract,
	'+='		=> \&_add_assign,
	'-='		=> \&_subtract_assign;
#	fallback	=> 1;

sub _compare {
	my ($left, $right) = @_;
	return $left->epoch <=> $right->epoch;
}

#right may be a string
sub _compare_str {
	my ($left, $right) = @_;
	if ( ! ref $right ) {
		return $left->_to_string cmp $right;
	}
	confess "can't compare $left and $right";
}

sub _to_string {
	my $self = shift;
	return strftime $self->format, gmtime ( $self->epoch ) ;
}

#todo обработку interval, исключений, и других случаев
sub _add {
	my ($self, $value) = @_;
	if ( looks_like_number($value) and $value == int($value) ) {
		return $self->epoch + $value;
	}
	elsif ( ref $value eq "Local::Date::Interval" ) {
		my $epoch = $self->epoch + $value->duration;
		return Local::Date->new(epoch => $epoch);
	}
	else {
		confess "incorect operand $value in + operation";
	}
}

sub _subtract {
	my ($self, $value) = @_;
	if ( looks_like_number($value) and $value == int($value) ) {
		return $self->epoch - $value;
	}
	elsif ( ref $value eq "Local::Date::Interval" ) {
		my $epoch = $self->epoch - $value->duration;
		return Local::Date->new(epoch => $epoch);
	}
	elsif ( ref $self eq "Local::Date" ) {
		my $duration = $self->epoch - $value->epoch;
		return Local::Date::Interval->new(duration => $duration);	
	}
	else {
		confess "incorect operand $value in - operation";
	}
}

sub _add_assign {
	my ($self, $value) = @_;
	$self->_set_epoch($self->epoch + $value);
	return $self;
}

sub _subtract_assign {
	my ($self, $value) = @_;
	$self->_set_epoch($self->epoch - $value);
	return $self;
}
#проверяем правильно ли вызван конструктор.

for my $attr ( qw(seconds minutes hours year month day) ) {
	before "_build_$attr" => sub {
		my $self = shift;
		confess "can't get $attr, because epoch attribute was not set!"
			unless $self->_has_epoch;
	};
}

before "_build_epoch" => sub {
	my $self = shift;
	for my $date_part ( qw (seconds minutes hours year month day) ) {
		unless (eval "\$self->_has_$date_part") {
			confess "can't get epoch, because $date_part was not set!";
		}
	}
};


#обеспечиваем консистентность объекта

after '_set_epoch' => sub {
	my $self = shift;
	for my $date_part ( qw( seconds minutes hours year month day ) ) {
		eval "\$self->_clear_$date_part";
	}
};




1;