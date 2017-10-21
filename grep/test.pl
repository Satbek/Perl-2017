#!/usr/bin/perl
use 5.016;
use DDP;
use warnings;
use Grep;
use Test::More tests => 29;

#ABC flags
is (Grep::ABC_get_num("          123"), 123, "left spaces");
is (Grep::ABC_get_num("  123  "), 123, "left right spaces");
is (Grep::ABC_get_num("123  "), 123, "right spaces");
eval{Grep::ABC_get_num("sadf11")};
ok($@, "grep: sadf11: invalid context length argumen");
eval{Grep::ABC_get_num("11sadf")};
ok($@, "grep: 11sadf: invalid context length argumen");

#ARGV
@ARGV = qw /asdf dfs 234 sfda \d asdf 3234v sd \s asf +++ asdf/;

eval{Grep::check_ARGV(\@ARGV)};
ok($@, ">1 params in @ARGV");
@ARGV = ();
eval{Grep::check_ARGV(\@ARGV)};
ok($@, "0 params in @ARGV");

@ARGV = qw /           1/;
Grep::check_ARGV(\@ARGV);
is($ARGV[0],"1", 'pattern without quotes');
@ARGV = ("  1");
Grep::check_ARGV(\@ARGV);
is($ARGV[0],"  1", 'pattern with quotes');

my ($pattern, $new_pattern);

#process_i_re
is(Grep::process_i_re('\d'), qr/\d/i, "i-flag works simple string");
$pattern = '\d+\w+fsda  f ';
is(Grep::process_i_re($pattern), qr/$pattern/i, "i-flag works complex_string");

#process_v
$pattern = "str";
$new_pattern = Grep::process_v($pattern);
ok("string" !~ /$new_pattern/, "string vs str");
ok("sd" =~ /$new_pattern/, "sd vs string");
$pattern = "str\$";
$new_pattern = Grep::process_v($pattern);
ok("str" !~ /$new_pattern/, "str vs str");
ok("astr" !~ /$new_pattern/, "astr vs str");

#process_F
$pattern = '\d';
$new_pattern = Grep::process_F($pattern);
is ($pattern =~ /$new_pattern/, 1, "F-simple string");
$pattern = '\dfds+asdf.?*dsaf[^gdfs]?:(fds)';
$new_pattern = Grep::process_F($pattern);
is ($pattern =~ /$new_pattern/, 1, "F-complex string");

#test_together
#F+i
$pattern = '\dA';
$new_pattern = Grep::process_F($pattern);
my $re = Grep::process_i_re($new_pattern);
my $str = '\da';
is($str =~ $re, 1, "F + i works");

#v+F
$pattern = '\dA';
$new_pattern = Grep::process_F($pattern);
$new_pattern = Grep::process_v($new_pattern);# чтобы оглядывание работало, нужно в таком порядке
ok('\dA' !~ /$new_pattern/, '\dA !~ '."$new_pattern");
ok('3A' =~ /$new_pattern/, '3A =~ '."$new_pattern");
ok('\da' =~ /$new_pattern/, '\da =~ '."$new_pattern");

#v+F+i
$pattern = '\dA';
$new_pattern = Grep::process_F($pattern);
$new_pattern = Grep::process_v($new_pattern);# чтобы оглядывание работало, нужно в таком порядке
$re = Grep::process_i_re($new_pattern);
ok('\dA' !~ $re, '\dA !~ '."$re");
ok('3A' =~ $re, '3A =~ '."$re");
ok('\da' !~ $re, '\da !~ '."$re");

#test_data
my @data;
push @data, $_ for (1..40);
my ($A, $B, $C, $c, $n);
$A = 1;
$re = qr/^3/;
my $res = "3\n4\n--\n30\n31\n32\n33\n34\n35\n36\n37\n38\n39\n40\n";
is(Grep::create_output($A, $B, $C , $c, $n, $re ,\@data), $res, "simple data");

$B = 1;
$re = qr/1/;
$res = "1\n2\n--\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22\n--\n30\n31\n32\n";
is(Grep::create_output($A, $B, $C , $c, $n, $re ,\@data), $res, "simple data2");

$C = 3;
$B = 0;
$A = 0;
$re = qr/1/;
$res = "1\n2\n3\n4\n--\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22\n23\n24\n--\n28\n29\n30\n31\n32\n33\n34\n";
is(Grep::create_output($A, $B, $C , $c, $n, $re ,\@data), $res, "simple data3");

$C = 3;
$B = 0;
$A = 0;
$c = 1;
$re = qr/1/;
$n = 1;
$res = 13;
is(Grep::create_output($A, $B, $C , $c, $n, $re ,\@data), $res, "-c flag");

$C = 3;
$B = 0;
$A = 0;
$c = 0;
$re = qr/1/;
$n = 1;
$res = "1:1\n2-2\n3-3\n4-4\n--\n7-7\n8-8\n9-9\n10:10\n11:11\n12:12\n13:13\n14:14\n15:15\n16:16\n17:17\n18:18\n19:19\n20-20\n21:21\n22-22\n23-23\n24-24\n--\n28-28\n29-29\n30-30\n31:31\n32-32\n33-33\n34-34\n";
is(Grep::create_output($A, $B, $C , $c, $n, $re ,\@data), $res, "-n flag");
