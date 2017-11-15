#!/usr/bin/perl
use DDP;
use 5.016;
use warnings;
use Archive::Zip;
use Archive::Zip::MemberRead;
use DBI;
use Encode qw(decode encode);
binmode STDOUT, ":utf8:";
use utf8;
use Try::Tiny;
my $dbh = DBI->connect("DBI:Pg:dbname=social_network;host=127.0.0.1;port=5432", 'satbek', "kocpak", 
	{ pg_utf8_strings => 1 }) or die "Can't connect to database ".DBI->errstr;

my $sth = $dbh->prepare("INSERT INTO users values (?, ?)") or die DBI->errstr;

my $zip = Archive::Zip->new("../etc/user.zip");
my $fh  = Archive::Zip::MemberRead->new($zip, "user");
while (my $line = decode('UTF-8',$fh->getline())) {
	my ($id, $name, $surname) = split " ", $line;
	$sth->execute($name, $surname);
	say $id, $name, $surname;
}

$zip = Archive::Zip->new("../etc/user_relation.zip");
$fh  = Archive::Zip::MemberRead->new($zip, "user_relation");
$sth = $dbh->prepare("INSERT INTO users_relations values (?, ?)") or die DBI->errstr;
while (my $line = $fh->getline()) {
	my ($id1, $id2) = split " ", $line;
	say DBI->errstr unless $sth->execute($id1, $id2);
}
