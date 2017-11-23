package Local::Model;
use 5.016;
use warnings;
use DBI;
use JSON::XS;
use DDP;
use Cache::Memcached::Fast;

sub new {
	my $class = shift;
	my $self = {};
	my $config = shift;
	open(my $fd, "<", "../Config/$config") or die $!;
	my %config_db = %{decode_json (<$fd>)};
	my $config_mem = decode_json (<$fd>);
	close($fd);
	my $dbh = DBI->connect("$config_db{dsn};host=$config_db{host};port=$config_db{port}", $config_db{user}, $config_db{password})
			or die "Can't connect to database ".DBI->errstr;
	my $mem = Cache::Memcached::Fast->new($config_mem);
	$self->{data} = "";
	$self->{dbh} = $dbh;
	$self->{mem} = $mem;
	return bless $self, $class;
}

sub get_data {
	my $self = shift;
	return $self->{data};
}

sub _friends {
	my ($self, $user1, $user2) = @_;
	$user1 += 0;
	$user2 += 0;
	my $sth = $self->{dbh}->prepare(
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
	my $self = shift;
	my $sth = $self->{dbh}->prepare(
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
	my ($self, $user1, $user2) = @_;
	my (@queue, @paths, @parents, @visited);
	push @queue, $user1;
	my $sth = $self->{dbh}->prepare("select id2 from users_relations where id1 = ?");
	$paths[$user1] = 0;
	if (my $count = $self->{mem}->get("$user1.$user2") ||  $self->{mem}->get("$user2.$user1")) {
	 	return $count;
	}
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
				$self->{mem}->set("$user1.$child", $paths[$child]);
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
	return $paths[$user2];
}

sub set_data {
	my $self = shift;
	die if $self->{data};
	my ($method, @args) = @_;
	local $" = ',';
	$self->{data} = eval "_$method ".'$self,'."@args" || die $!;
}

sub erase_data {
	my $self = shift;
	$self->{data} = undef;
}

1;