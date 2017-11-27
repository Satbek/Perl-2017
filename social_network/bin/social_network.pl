#!/usr/bin/env perl
use strict;
use warnings;
use 5.016;
use DDP;
my $Bin;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::Model;
use Local::View;
use Local::Controller;
use Getopt::Long;

my $Model = Local::Model->new("Config.txt");

my $Controller = Local::Controller->new(@ARGV);
#p $Controller;
$Controller->set_data($Model);

my $View = Local::View->new();
$View->set_data_type("to_json");
p $View->get_data($Model);