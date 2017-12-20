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

sub encrypt_password {
	#возращает пароль какой он будет в базе
	#todo шифрование и проверка есть ли это в базе
	#пользователь ввел -> в базе
	my $encr_passwd = shift;
	return $encr_passwd;
};

sub decrypt_password {
	#todo
	#в базе -> пользователь ввел
	my $decr_passwd = shift;
	return $decr_passwd;
}

#public методы
#todo, написать класс Note для работы с заметками
sub create_note {

}

sub get_notes {

}


#вернет 1 если сущетсвует пользователь с таким логином и паролем
#0 иначе
sub login {
	my $self = shift;
	my $username = $self->username;
	my $password = $self->password;
	#шифруем пароль
	$password = encrypt_password($password);
	my $sth = database->prepare('select id from users where 
			username = ? and password = ?');
	$sth->execute($username, $password);
	my $res = $sth->fetchrow_hashref();
	return $res->{id} ? 1 : 0;
}

sub _user_exist {
	my $self = shift;
	my $username = $self->username;
	my $sth = database->prepare('select id from users where 
			username = ?');
	$sth->execute($username);
	my $res = $sth->fetchrow_hashref();
	return $res->{id} ? 1 : 0;
}

#вернет 1 если смогла зарегистрировать, 0 если нет
sub register {
	my $self = shift;
	my $username = $self->username;
	my $password = $self->password;
	$password = encrypt_password($password);
	if (!$self->_user_exist) {
		#если его не существует, то добавим его в базу
		my $sth = database->prepare("insert into users (username, password)
					values (?, ?)");
		$sth->execute($username, $password);
		return 1;
	} else {
		return 0;
	}
}

1;