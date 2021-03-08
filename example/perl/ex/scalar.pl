#!/usr/bin/perl

$age = 25;
$name = "John Paul";
$salary = 1445.50;

print "Age = $age\n";
print "Name = $name\n";
print "Salary = $salary\n";

$integer = 200;
$negative = -300;
$floating = 200.340;
$bigfloat = -1.2E-23;

# 377 octal, same as 255 decimal
$octal = 0377;

# FF hex, also 255 decimal
$hexa = 0xff;

print "integer = $integer\n";
print "negative = $negative\n";
print "floating = $floating\n";
print "bigfloat = $bigfloat\n";
print "octal = $octal\n";
print "hexa = $hexa\n";

print "\n";

$var = "This is string scalar!";
$quote = 'I m inside single quote - $var';
$double = "This is inside double quote - $var";

$escape = "This example of escape -\t Hello, World!";

print "var = $var\n";
print "quote = $quote\n";
print "double = $double\n";
print "escape = $escape\n";

$str = "hello" . "world";
$num = 5 + 10;
$mul = 4 * 5;
$mix = $str . $num;

print "str = $str\n";
print "num = $num\n";
print "mul = $mul\n";
print "mix = $mix\n";

print "\n";

$string = 'This is
a multiline
string';

print "$string\n";
print "\n";

print <<EOF;
This is
a multiline
string
EOF

$smile = v9786;
$foo = v102.111.111;
$martin = v77.97.114.116.105.110;

print "smile = $smile\n";
print "foo = $foo\n";
print "martin = $martin\n";

print "\n\n";

print "File name ". __FILE__ ."\n";
print "Line Number ". __LINE__ ."\n";
print "Package ". __PACKAGE__ ."\n";
