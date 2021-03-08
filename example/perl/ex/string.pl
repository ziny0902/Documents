#!/usr/bin/perl
#
use v5.32.0;

use feature "switch";

use warnings;
use strict;


my $long_string = "Random Long String";

say "Length of String" , length $long_string;

printf("Long is at %d \n", index $long_string, "Long");
printf("Last g is at %d \n", rindex $long_string, "g");

$long_string = $long_string . ' isn\'t that long';

say "Index 7 through 10", substr
$long_string, 7, 4;

my $animal = "animals";

printf("Last character is %s\n", chop $animal);

my $no_newline = "No Newline\n";
chomp $no_newline;

printf("Uppercase : %s \n", uc $long_string );
printf("Lowercase: %s \n", lc $long_string );
printf("1st Uppercase %s \n", ucfirst $long_string );

$long_string =~ s/ /, /g;
say $long_string;

my $two_times = "What I said is " x 2;
say $two_times;

my @abcs = ('a' .. 'z');
print join(", ", @abcs), "\n";

my $letter = 'c';
say "Next Letter ", ++$letter;


my $s = q^A string with different delimiter ^;
print($s,"\n");
print(length($s), "\n");
print("To upper case:\n");
print(uc($s), "\n");

print("To lower case:\n");
print(lc($s), "\n");

$s = "Learning Perl is easy\n";
my $sub = "Perl";
my $p = index($s, $sub);
print(qq\The substring "$sub" found at position "$p" in string "$s"\, "\n");
substr($s, $p, length($sub), "");
print($s, "\n");
print "This is" . "concatenation operator" . "\n";
print "a message " x 4, "\n";
