#!/usr/bin/perl
use 5.016;
use warnings;
use DDP;
use Simple;
use Test::More tests => 9;

my $str = "fsd:fds,a:a";
my $obj = Simple->new($str);
is($obj->get("fsd"), "fds", "works with good data");
is($obj->get("a"), "a", "works with good data");

is($obj->get("b","a"),"a","gets default data");

$obj = Simple->new("");
is($obj, undef, "empty string");

$obj = Simple->new("s:s");
is($obj->get("s"),"s", "one element");

$obj = Simple->new("s,a,a");
is($obj, undef, "without :");

$obj = Simple->new(":");
is($obj->get("undef"), "", "empty value and key");

$obj = Simple->new("a:a,v:d,a:w,");
is($obj, undef, "single , after string");

$obj = Simple->new(",a:a");
is($obj, undef, "single , before string");