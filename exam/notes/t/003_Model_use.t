#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More tests => 3;
BEGIN { use_ok("Model::Users::User"); }
BEGIN { use_ok("Model::Users::User_Creator"); }
BEGIN { use_ok("Model::Users::Moderator"); }
BEGIN { use_ok("Model::Notes::Note"); }

