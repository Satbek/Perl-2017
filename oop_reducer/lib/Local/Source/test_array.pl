#!/usr/bin/perl
use 5.016;
use warnings;
use Array;
use DDP;
use Test::More tests => 4;
my $obj = Array->new(array => [1,2]);
is ($obj->next, 1, "return value" );
is ($obj->next, 2, "return value" );
is ($obj->next, undef, "maintain undef");
is ($obj->next, undef, "maintain undef");