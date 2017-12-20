#!/usr/bin/perl
use strict;
use warnings;
use 5.016;
use FindBin;
use DBI;
use lib "$FindBin::Bin/../lib";
use Model::Users::User;
use DDP;

my $dbh = DBI->connect("DBI:Pg:dbname=notes;host=127.0.0.1;port=5432", "notes", "notes")
			or die "Can't connect to database ".DBI->errstr;

use Test::More tests => 4;

#test1
my $user = Model::Users::User->new(username => "admin", password => "passw");
is(ref $user, "Model::Users::User", "created user");

#test2
my $user2 = eval { Model::Users::User->new(username => "admin\\", password => "passwm3m ") };
is(ref $user2, '', "incorrect login, password didnt't pass");
#say $@;

#test3
my $user3 = eval { Model::Users::User->new(username => "admin\\", password => "passwm3m") };
is(ref $user3, '', "incorrect login didnt't pass");
#say $@;

#test4
#todo, переписать т.к. появиться вася пупкин настоящий
#логинит существующего пользователя
my $sth = $dbh->prepare("insert into users (username, password) 
						values ('vasia', 'pupkin')");
$sth->execute;
my $user4 = Model::Users::User->new(username => "vasia", password => "pupkin");
is($user4->login, 1, 'loginned existed user');
$sth = $dbh->prepare("delete from users where username = 'vasia' and password = 'pupkin';");
$sth->execute;

#test5
#не логинит несущствующего пользователя
$sth = $dbh->prepare("insert into users (username, password) 
						values ('vasia', 'pupkin')");
$sth->execute;
my $user5 = Model::Users::User->new(username => "vasilii", password => "pupkin");
is($user5->login, 0, 'do not unexisted user');
$sth = $dbh->prepare("delete from users where username = 'vasia' and password = 'pupkin';");
$sth->execute;

#test6
#регистрация пользователя с корректными данными
my $user6 = Model::Users::User->new(username => "vasilisa", password => "pupkin");
is($user6->register, 1, 'can register correct user');
$dbh->do("delete from users where username = 'vasilisa' and password = 'pupkin';");

#test7
#попытка регистрации несуществующего пользователя
my $user7 = Model::Users::User->new(username => "vasilisa", password => "pupkin");
$user7->register;
my $user8 = Model::Users::User->new(username => "vasilisa", password => "pupki");
is($user8->register, 0, 'can\'t register if user with this username exists');
$dbh->do("delete from users where username = 'vasilisa';");