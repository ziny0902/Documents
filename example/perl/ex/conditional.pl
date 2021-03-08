#!/usr/bin/perl
#

use v5.32.0;

# if - elsif - else
my $age = 80;
my $is_not_intoxicated = 1;
my $age_last_exam = 16;

if ($age < 16) {
  say "You can't drive";
} elsif(!$is_not_intoxicated){
  say "You can't drive";
}else{
  say "you can drive";
}

if (($age >= 1) && ($age < 16)){
  say "you can't drive";
} elsif(!$is_not_intoxicated){
  say "you can't drive";
} elsif(($age >= 80) && (($age > 100)||(($age - $age_last_exam) > 5))){
  say "you can't drive";
} else {
  say "you can drive";
}

# eq

if ('a' eq 'b'){
  say "a equal b";
} else {
  say "a doesn't equal b";
}

# () ? <command> : <command>
say (($age > 18) ? "Can Vote" : "Can't vote");


my $name = "Ali";
my $age = 10;

my $status = ($age > 60) ? "A senior citizen" : "Not a senior citizen";

print "$name is - $status\n";

$a = 20;
# check the boolean condition using unless statement
unless( $a < 20 ) {
	# if condition is false then print the following
	print "a is not less than 20\n";
}
print "value of a is : $a\n";

$a = "";
#check the boolean condition using unless statement
unless ($a) {
	# if condition is false then print the following
	print "a has a false value\n";
}
print "value of a is : $a\n";

$a = 20;

unless( $a == 20 ) {
	print "a has a value which is not 20\n";
} elsif ( $a  == 20 ) {
	print "a has a value which is 20\n";
}

use Switch;

my $var = 15;
my @array = (10, 20, 30);
my %hash = ('key1' => 15, 'key2' => 20);

switch($var) {
	case 10 	{ print "number 10\n" }
	case "a"	{ print "string a" }
	case [1..10,42] { print "number in list\n" }
	case (\@array)	{ print "number in array\n" }
	case (\%hash)	{ print "entry in hash\n" }
	else		{ print "previous case not true\n" }
}
print "$hash{'key1'}\n";
