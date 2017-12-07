#!/usr/bin/env perl

# use EV;
use 5.016;
use AnyEvent::HTTP;
use URI;
use DDP;
use Getopt::Long qw(:config no_ignore_case);;
use Web::Query;

sub say_server_response {
	my %hdr = %{shift()};
	say "\tHTTP/".$hdr{HTTPVersion}." ".$hdr{Status}." ".$hdr{Reason};
	delete $hdr{HTTPVersion};
	delete $hdr{Status};
	delete $hdr{Reason};
	for my $head(keys %hdr) {
		say "\t$head: ".$hdr{$head};
	}
}

my %config;
my %seen;
my $url = "http://search.cpan.org";
$url = shift @ARGV;
die "give me url!" unless $url =~ /^https?:/;
$url =~ s/([^\/])$/$1\//;
$seen{$url} = 0;
#p $url;
GetOptions('N=i' => \$config{N}, 'r' => \$config{r}, 'l=i' => \$config{l}, 'L' => \$config{L}, 'S' => \$config{S});

$config{N} = 0 unless $config{r};

$config{N} //= 1 if $config{r};

$config{l}++ unless $config{l};

#p %config;

my $host = URI->new($url)->host;

my @queue = ($url);

my $ACTIVE = 0;
$AnyEvent::HTTP::MAX_PER_HOST = my $LIMIT = 100;
$config{N} = $LIMIT if $config{N} > $LIMIT;

my $FILE_COUNT = 0;

my $cv = AE::cv;
$cv->begin;
my $worker;$worker = sub {
	my $uri = shift @queue or return;
 	$cv->end if $seen{$uri} == $config{l};
	say "[$ACTIVE:$LIMIT] Start loading $uri (".(0+@queue).")";
	$ACTIVE++;
	$cv->begin;
	http_request
		HEAD => $uri,
		timeout => 10,
		sub {
			my ($body,$hdr) = @_;
			if (exists $hdr->{'content-length'}) {
				$cv->begin;
				http_request
					GET => $uri,
					timeout => 10,
					sub {
						my ($body,$hdr) = @_;
						say_server_response($hdr) if $config{S};
						say "End loading $uri: $hdr->{Status}";
						$ACTIVE--;
						if ($hdr->{Status} == 200) {
							# my @href = $body =~ m{<a[^>]*href=(|"([^"]+)"|(\S+))}i;
							$FILE_COUNT++;
							my $open = open(my $fh, ">", "$FILE_COUNT.txt");
							syswrite($fh, $body) if $open;
							close($fh);
							#my @href = $body =~ m{<a[^>]*href="([^"]+)"}sig;
							my @href;
							Web::Query->new($body)->find('a')->each(sub {
									my ($i, $elem) = @_;
									my $rel = $elem->attr('href');
									push @href, $rel;
							});
							for my $href (@href) {
								next if $href =~ /^https?:/ and $config{L};
								my $new = URI->new_abs( $href, $hdr->{URL} );
								next if $new !~ /^https?:/;
								next if $new->host ne $host;
								next if exists $seen{$new};
								$seen{$new} = $seen{$hdr->{URL}} + 1;
								push @queue, $new;
							}
						}
						else {
							warn "Failed to fetch: $hdr->{Status} $hdr->{Reason}";
						}
						
						if (@queue) {
							$worker->() for 1..$config{N} - $ACTIVE;
						}
						$cv->end;
					}
				;
			}
			else {
				say "Skip loading $uri: $hdr->{Status} ($hdr->{'content-length'})";
				$ACTIVE--;
				if (@queue) {
					$worker->() for 1..$config{N} - $ACTIVE;
				}
			}
			$cv->end;
		}
	;
};$worker->(); $cv->end;

$cv->recv;