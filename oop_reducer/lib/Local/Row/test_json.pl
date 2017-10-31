#!/usr/bin/perl
use 5.016;
use warnings;
use JSON;
use DDP;
use Test::More tests => 2;
my $obj = JSON->new("{\"price\": 1}");
is ($obj->get("price", "price"), 1,"works on JSON");

$obj = JSON->new("asdfsdf");
is ($obj, undef, "works on not JSON");