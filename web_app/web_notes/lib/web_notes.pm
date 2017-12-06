package web_notes;
use Dancer2;
use Dancer2::Plugin::Database;
use Digest::CRC qw/crc64/;
use HTML::Entities;
use DDP;
use 5.016;

our $VERSION = '0.1';
my $user;


get '/' => sub {
	if (session "logged") {
		return template 'index' => {logged => 1, user_name => $user};
	}
	else {
		return template 'index';
	}
};


any ['get', 'post'] => '/login' => sub {
	redirect "/" if session("logged");
	$user = params->{username};
	my $password = params->{password};
	session "logged" => true;
	redirect '/';
};


get '/logout' => sub {
	app->destroy_session;
	redirect '/';
};

true;
