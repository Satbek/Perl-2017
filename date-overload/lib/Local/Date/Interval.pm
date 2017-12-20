package Local::Date::Interval;
use Moose::Util::TypeConstraints;
use Moose;
use locale;
use POSIX qw ( locale_h );
use Carp qw(confess);
use DDP;
use FindBin;
use lib "$FindBin::Bin/..";
use Local::DateTypes;
use Scalar::Util qw(looks_like_number);

#задаем локаль
setlocale(LC_TIME, "en_US.UTF-8");

#определяем типы для валидации данных
subtype 'days'
	=> as 'Int'
	=> where { $_ >= 0 }
	=> message { "$_ can't be a days count" };

subtype 'duration'
	=> as 'Int'
	=> where { $_ >= 0 }
	=> message { "$_ can't be a duration in seconds!" };

#определяем атрибуты
for my $name ( qw( seconds minutes hours days ) ) {
	has $name => (
		is => 'ro',
		isa => "$name",
		builder => '_build_' . $name,
		lazy => 1,
		required => 1,
		predicate => "_has_$name",
		clearer => "_clear_$name",
	);
}

has 'duration' => (
	is => 'ro',
	isa => 'duration',
	lazy => 1,
	required => 1,
	builder => '_build_duration',
	predicate => '_has_duration',
	writer => '_set_duration',
);

#builders

#1st constructor
sub _build_seconds {
	my $self = shift;
	return ( gmtime($self->duration) )[0];
}

sub _build_minutes {
	my $self = shift;
	return ( gmtime($self->duration) )[1];
}
	
sub _build_hours {
	my $self = shift;
	( gmtime($self->duration) )[2];
}

#может быть больше 31го дня
sub _build_days {
	my $self = shift;
	return int ( $self->duration / 86400 );
}


#2nd  constructor
sub _build_duration {
	my $self = shift;
	return 24 * 60 * 60 * $self->days + 60 * 60 * $self->hours +
			60 * $self->minutes + $self->seconds;
}

#проверяем правильно ли вызваны конструкторы
for my $attr ( qw(seconds minutes hours days) ) {
	before "_build_$attr" => sub {
		my $self = shift;
		confess "can't get $attr, because duration attribute was not set!"
			unless $self->_has_duration;
	};
}

before "_build_duration" => sub {
	my $self = shift;
	for my $interval_part ( qw (seconds minutes hours days) ) {
		unless (eval "\$self->_has_$interval_part") {
			confess "can't get duration, because $interval_part was not set!";
		}
	}
};

#переопределяем интервалы
use overload
	'""'		=> \&_to_string,
	"<=>"		=> \&_compare,
	"cmp"		=> \&_compare_str,
	'+'			=> \&_add,
	'-'			=> \&_subtract,
	'+='		=> \&_add_assign,
	'-='		=> \&_subtract_assign;

sub _to_string {
	my $self = shift;
	return $self->days." days, ".$self->hours." hours, ".$self->minutes." minutes, ".$self->seconds." seconds";
}

sub _compare {
	my ($left, $right) = @_;
	if ( ref $right eq "Local::Date::Interval" ) {
		return $left->duration <=> $right->duration;
	}
	elsif ( looks_like_number($right) and $right == int($right) and $right >= 0 ) {
		return $left->duration <=> $right;
	}
	else {
		confess "can't compare $left and $right";
	}
}

#right may be a string
sub _compare_str {
	my ($left, $right) = @_;
	if ( ! ref $right ) {
		return $left->_to_string cmp $right;
	}
	confess "can't compare $left and $right";
}

#todo обработку interval, исключений, и других случаев
sub _add {
	my ($self, $value) = @_;
	if ( looks_like_number($value) and $value == int($value) ) {
		return $self->duration + $value;
	}
	elsif ( ref $value eq "Local::Date::Interval" ) {
		my $duration = $self->duration + $value->duration;
		return Local::Date::Interval->new(duration => $duration);
	}
	else {
		confess "incorect operand $value in + operation";
	}
}

sub _subtract {
	my ($self, $value) = @_;
	if ( looks_like_number($value) and $value == int($value) ) {
		return $self->duration - $value;
	}
	elsif ( ref $value eq "Local::Date::Interval" ) {
		my $duration = $self->duration - $value->duration;
		return Local::Date::Interval->new(duration => $duration);
	}
	else {
		confess "incorect operand $value in - operation";
	}
}

sub _add_assign {
	my ($self, $value) = @_;
	if ( looks_like_number($value) and $value == int($value) ) {
		$self->_set_duration($self->duration + $value);
		return $self;
	}
	elsif ( ref $value eq "Local::Date::Interval" ) {
		my $duration = $self->duration + $value->duration;
		$self->_set_duration($duration);
		return $self;
	}
	else {
		confess "incorect operand $value in += operation";
	}
}

sub _subtract_assign {
	my ($self, $value) = @_;
	if ( looks_like_number($value) and $value == int($value) ) {
		$self->_set_duration($self->duration - $value);
		return $self;
	}
	elsif ( ref $value eq "Local::Date::Interval" ) {
		my $duration = $self->duration - $value->duration;
		$self->_set_duration($duration);
		return $self;
	}
	else {
		confess "incorect operand $value in -= operation";
	}
}

#обеспечиваем консистентность объекта
after '_set_duration' => sub {
	my $self = shift;
	for my $interval_part ( qw( seconds minutes hours days ) ) {
		eval "\$self->_clear_$interval_part";
	}
};

1;

1;
