@ary = (1, 3, sort 4, 2);
print @ary;         # prints 1324

# These evaluate exit before doing the print:
print($foo, exit);  # Obviously not what you want.
print $foo, exit;   # Nor is this.

# These do the print before evaluating exit:
(print $foo), exit; # This is what you want.
print($foo), exit;  # Or this.
print ($foo), exit; # Or even this.


# print ($foo & 255) + 1, "\n";
# 1 + 1, "\n";    # Obviously not what you meant.
print(($foo & 255) + 1, "\n");

$i = 0;  $j = 0;
print $i++;  # prints 0
print ++$j;  # prints 1

#Perl will not guarantee what the result of the above statements is.
print ++ $i + $i ++;

print ++($foo = "99");      # prints "100"
print ++($foo = "a0");      # prints "a1"
print ++($foo = "Az");      # prints "Ba"
print ++($foo = "zz");      # prints "aaa"

# Binary "=~" binds a scalar expression to a pattern match. Certain
# operations search or modify the string $_ by default. This operator
# makes that kind of operation work on some other string. The right
# argument is a search pattern, substitution, or transliteration. The left
# argument is what is supposed to be searched, substituted, or
# transliterated instead of the default $_.

(my $new = $old) =~ s/foo/bar/g;
my $new = ($old =~ s/foo/bar/gr);
my $new = $old =~ s/foo/bar/gr;


print '-' x 80;             # print row of dashes
print "\t" x ($tab/8), ' ' x ($tab%8);      # tab over
@ones = (1) x 80;           # a list of 80 1's
@ones = (5) x @ones;        # set all elements to 5

# Unary "+" has no effect whatsoever, even on strings.
# It is useful syntactically for separating a function name
# from a parenthesized expression that would otherwise be interpreted
# as the complete list of function arguments. 

chdir $foo    || die;       # (chdir $foo) || die
chdir($foo)   || die;       # (chdir $foo) || die
chdir ($foo)  || die;       # (chdir $foo) || die
chdir +($foo) || die;       # (chdir $foo) || die

chdir $foo * 20;    # chdir ($foo * 20)
chdir($foo) * 20;   # (chdir $foo) * 20
chdir ($foo) * 20;  # (chdir $foo) * 20
chdir +($foo) * 20; # chdir ($foo * 20)


use v5.10.1;
@array = (1, 2, 3, undef, 4, 5);
say "some elements undefined" if undef ~~ @array;


use v5.10.1;

my %hash = (red    => 1, blue   => 2, green  => 3,
            orange => 4, yellow => 5, purple => 6,
            black  => 7, grey   => 8, white  => 9);

my @array = qw(red blue green);

say "some array elements in hash keys" if  @array ~~  %hash;
say "some array elements in hash keys" if \@array ~~ \%hash;

say "red in array" if "red" ~~  @array;
say "red in array" if "red" ~~ \@array;

say "some keys end in e" if /e$/ ~~  %hash;
say "some keys end in e" if /e$/ ~~ \%hash;

use v5.10.1;
my @little = qw(red blue green);
my @bigger = ("red", "blue", [ "orange", "green" ] );
if (@little ~~ @bigger) {  # true!
    say "little is contained in bigger";
}


use v5.10.1;
sub make_dogtag {
  state $REQUIRED_FIELDS = { name=>1, rank=>1, serial_num=>1 };

  my ($class, $init_fields) = @_;

  die "Must supply (only) name, rank, and serial number"
      unless $init_fields ~~ $REQUIRED_FIELDS;
}


$object ~~ $number          # ref($object) == $number
$object ~~ $string          # ref($object) eq $string

use IO::Handle;
my $fh = IO::Handle->new();
if ($fh ~~ /\bIO\b/) {
    say "handle smells IOish";
}

# Bitwise And
print "Even\n" if ($x & 1) == 0;

# Bitwise Or and Exclusive Or
print "false\n" if (8 | 2) != 10;

$home =  $ENV{HOME}
      // $ENV{LOGDIR}
      // (getpwuid($<))[7]
      // die "You're homeless!\n";

@a = @b || @c;            # This doesn't do the right thing
@a = scalar(@b) || @c;    # because it really means this.
@a = @b ? @b : @c;        # This works fine, though.


unlink "alpha", "beta", "gamma"
        or gripe(), next LINE;

unlink("alpha", "beta", "gamma")
        || (gripe(), next LINE);

unless(unlink("alpha", "beta", "gamma")) {
  gripe();
  next LINE;
}


if (101 .. 200) { print; } # print 2nd hundred lines, short for
                           #  if ($. == 101 .. $. == 200) { print; }

next LINE if (1 .. /^$/);  # skip header lines, short for
                           #   next LINE if ($. == 1 .. /^$/);
                           # (typically in a loop labeled LINE)

s/^/> / if (/^$/ .. eof());  # quote body

# parse mail messages
while (<>) {
  $in_header =   1  .. /^$/;
  $in_body   = /^$/ .. eof;
  if ($in_header) {
      # do something
  } else { # in body
      # do something else
  }
} continue {
  close ARGV if eof;             # reset $. each file
}

# This program will print only the line containing "Bar". If the range
# operator is changed to "...", it will also print the "Baz" line.
@lines = ("   - Foo",
          "01 - Bar",
          "1  - Baz",
          "   - Quux");

foreach (@lines) {
  if (/0/ .. /1/) {
      print "$_\n";
  }
}

for (101 .. 200) { print }      # print $_ 100 times
@foo = @foo[0 .. $#foo];        # an expensive no-op
@foo = @foo[$#foo-4 .. $#foo];  # slice last 5 items

@list = (2.18 .. 3.14); # same as @list = (2 .. 3);

@z2 = ("01" .. "31");
print $z2[$mday];

@numbers = ( 0+$first .. 0+$last );
@alphabet = ("A" .. "Z");
$hexdigit = (0 .. 9, "a" .. "f")[$num & 15];

printf "I have %d dog%s.\n", $n,
        ($n == 1) ? "" : "s";

$x = $ok ? $y : $z;  # get a scalar
@x = $ok ? @y : @z;  # get an array
$x = $ok ? @y : @z;  # oops, that's just a count!

# The operator may be assigned to if both the 2nd and 3rd arguments are
# legal lvalues (meaning that you can assign to them):
($x_or_y ? $x : $y) = $z;

$x = $y or $z;              # bug: this is wrong
($x = $y) or $z;            # really means this
$x = $y || $z;              # better written this way


