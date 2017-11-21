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
	$user1 += 0;
	$user2 += 0;
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
	my ($user1, $user2) = @_;
	my @queue;
	push @queue, $user1;
	my @visited = (0) x 50000;
	my $sth = $dbh->prepare("select id2 from users_relations where id1 = ?");
	my @parents = (0) x 50000;
	my @paths = (0) x 50000;
	$paths[$user1] = 0;
	while (@queue) {
		#say $#queue;
		my $node = shift @queue;
		unless (defined $node) {
			return undef;
		}
		if ($node == $user2) {
			$visited[$node]++;
			last;
		}
		$sth->execute($node);
		my @arr = map {$_ = $_->[0]} @{$sth->fetchall_arrayref()};
		for my $child (@arr) {
			unless ($visited[$child]) {
				push @queue, $child;
				$visited[$child]++;
				$parents[$child] = $node;
				$paths[$child] = $paths[$node] + 1;
			}
		}
	}
	my @path;
	for (my $v = $user2; $v != $user1; $v = $parents[$v]) {
		unshift @path, $v;
	}
	my %res = (
		path_length => scalar @path,
		path => \@path,
	);
	return $res{path_length}; 
	
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