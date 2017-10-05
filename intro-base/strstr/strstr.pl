#!/usr/bin/perl
use strict;
use warnings;
use DDP;
use 5.018;
die "bad arguments" unless @ARGV == 2;
my ($first, $second) = @ARGV;
my $pos;
if (($pos = index $first, $second) == -1) {
	warn "Not found";
	exit;
}
say $pos;
say substr($first,$pos);