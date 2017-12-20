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
say $@;

#test3
my $user3 = eval { Model::Users::User->new(username => "admin\\", password => "passwm3m") };
is(ref $user3, '', "incorrect login didnt't pass");
say $@;

#test4

