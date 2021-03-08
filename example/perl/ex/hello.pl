#!/usr/bin/perl

# This will print "Hello, World"

print "Hello, world\n";
$a = 10;
$var = <<"EOF";
This is the syntax for here document and it will continue
until it encounters a EOF in the first line.
this is case of double quote so variable value will be
interpolated. For example value of a = $a
EOF

print "$var\n";

$result = "This is \"number\"";
print "$result\n";
print "\$result\n";

# This is case of interpolation.
$str = "Welcome to \ntutorialspoint.com!";
print "$str\n";

#This is case of non-interpolation.
$str = 'Welcome to \ntutorialpoint.com!';
print "$str\n";

#Only W will become upper case.
$str = "\uwelcome to tutorialpoint.com!";
print "$str\n";

# Whole line will become capital.
$str = "\UWelcome to tutorialspoint.com!";
print "$str\n";

# A portion of line will become capital.
$str = "Welcome to \Ututorialpoint\E.come!";
print "$str\n";

# Backslash non alpha-numeric including spaces.
$str = "\QWelcome to tutorialpoint's family";
print "$str\n";

