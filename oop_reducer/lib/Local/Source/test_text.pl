#!/usr/bin/perl
use 5.016;
use warnings;
use Text;
use DDP;
use Test::More tests => 4;
my $obj = Text->new(text => "asdf\nasdfd\n\n");
is($obj->next, "asdf", "simple text");
is($obj->next, "asdfd", "simple text");
is($obj->next, "", "return empty");
is($obj->next, undef, "return undef");