package Local::Model;
use 5.016;
use warnings;
use DBI;
use JSON::XS;
use DDP;

my $data;
my $dbh;
sub new {
	shift;
	my $config = shift;
	open(my $fd, "<", "../Config/$config") or die $!;
	my %config = %{decode_json (<$fd>)};
	close($fd);
	$dbh = DBI->connect("$config{dsn};host=$config{host};port=$config{port}", $config{user}, $config{password})
			or die "Can't connect to database ".DBI->errstr;
	return bless {};
}

sub get_data {
	return $data;
}

sub _friends {
	my ($user1, $user2) = @_;
	my $sth = $dbh->prepare(
		"select name, surname, id from (
			select id2 from (
				select id2 as id2_ from users_relations where id1 = ?
			) as us1 join (
				select id2 from users_relations where id1 = ?
			) as us2 on (us1.id2_ = us2.id2)
		) as ids join users on (ids.id2 = id);"
	);
	$sth->execute($user1, $user2);
	return $sth->fetchall_arrayref({});
}

sub _nofriends {
	my $sth = $dbh->prepare(
		"select name, surname, id from users join (
			select id as id_ from (
				users as us left join users_relations as us_rel on us.id = us_rel.id1
			) where id1 is null
		) as ids on id = ids.id_;"
	);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub _num_handshakes {
	
}

sub set_data {
	die if $data;
	shift;
	my ($method, @args) = @_;
	local $" = ',';
	$data = eval "_$method @args" || die $!;
}

sub erase_data {
	$data = undef;
}

1;