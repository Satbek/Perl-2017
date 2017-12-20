package Model::Users::User;
#здесь будет вся работа с бд, от юзера
use Moose;
use 5.016;
use DDP;
use Dancer2;
use Dancer2::Plugin::Database;
use Moose::Util::TypeConstraints;
use Carp qw(confess);

#username может состоять только из букв латинского алфавита и
#арабских цифр. длина от 5 до 15 символов

subtype 'username'
	=> as "Str"
	=> where { $_ =~ /^[a-zA-Z0-9]{5,15}$/ }
	=> message { "$_ can't be a username!" };

has 'username' => (
	is => 'ro',
	isa => "username",
	required => 1,
	writer => '_set_username',
);


#работа с паролем
#todo работа с шифромванием. в базе храним шифрованное

subtype 'password'
	=> as "Str"
	=> where { $_ =~ /^[a-zA-Z0-9]{5,20}$/ }
	=> message { "$_ can't be a password!" };

has 'password' => (
	is => 'ro',
	isa => "password",
	required => 1,
	writer => '_set_password',
);

#методы
sub create_note {

}

sub get_notes {

}

#if user_with
sub login {
	my $self = shift;
}

sub register {

}
#Проверяем есть ли такой юзер в базе
# after '_set_username' => sub {
# 	my $self = shift;
# 	my $username = $self->username;
# 	my $sth = database->prepare 
# 		('SELECT id from users where username = "$username"');
# 	unless ($sth->fetchrow_hashref()) {
# 		confess "There is no user with username $username";
# 	}
# };

1;