
print "Basset hounds got long ears" if length $ear >= 10;
go_outside() and play() unless $is_raining;

print "Hello $_!\n" for qw(world Dolly nurse);

# Both of these count from 0 to 10.
print $i++ while $i <= 10;
print $j++ until $j >  10;

# For "next" or "redo", just double the braces:
do {{
  next if $x == $y;
  # do something here
}} until $x++ > $z;

# For "last", you have to be more elaborate and put braces around it:
{
  do {
    last if $x == $y**2;
    # do something here
  } while $x++ <= $z;
}

# If you need both "next" and "last", you have to do both and also use a
# loop label:

LOOP: {
  do {{
    next if $x == $y;
    last LOOP if $x == $y**2;
    # do something here
  }} until $x++ > $z;
}

# The following all do the same thing:
if (!open(FOO)) { die "Can't open $FOO: $!" }
die "Can't open $FOO: $!" unless open(FOO);
open(FOO)  || die "Can't open $FOO: $!";
open(FOO) ? () : die "Can't open $FOO: $!";


# For example, when processing a file like /etc/termcap. If your input
# lines might end in backslashes to indicate continuation, you want to
# skip ahead and get the next record.
while (<>) {
  chomp;
  if (s/\\$//) {
    $_ .= <>;
    redo unless eof();
  }
  # now process $_
}

for (@ary) { s/foo/bar/ }

for my $elem (@elements) {
  $elem *= 2;
}

for $count (reverse(1..10), "BOOM") {
  print $count, "\n";
  sleep(1);
}

for (1..15) { print "Merry Christmas\n"; }

foreach $item (split(/:[\\\n:]*/, $ENV{TERMCAP})) {
  print "Item: $item\n";
}

use feature "refaliasing";
no warnings "experimental::refaliasing";
foreach \my %hash (@array_of_hash_references) {
  # do something which each %hash
}

for (my $i = 0; $i < @ary1; $i++) {
  for (my $j = 0; $j < @ary2; $j++) {
    if ($ary1[$i] > $ary2[$j]) {
      last; # can't go to outer :-(
    }
    $ary1[$i] += $ary2[$j];
  }
  # this is where that last takes me
}

WID: for my $this (@ary1) {
  JET: for my $that (@ary2) {
    next WID if $this > $that;
    $this += $that;
  }
}

See how much easier that was in idiomat
if ((my $color = <STDIN>) =~ /red/i) {
  $value = 0xFF0000;
}
elsif ($color =~ /green/i) {
  $value = 0x00FF00;
}
elsif ($color =~ /blue/i) {
  $value = 0x0000FF;
}
else {
  warn "unknown RGB component '$color', using black instead\n";
}

use v5.10.1;
for ($var) {
  when (/^abc/) { $abc = 1 }
  when (/^def/) { $def = 1 }
  when (/^xyz/) { $xyz = 1 }
  default       { $nothing = 1 }
}

use v5.10.1;
given ($var) {
  when (/^abc/) { $abc = 1 }
  when (/^def/) { $def = 1 }
  when (/^xyz/) { $xyz = 1 }
  default       { $nothing = 1 }
}

use feature ":5.10";
given ($n) {
# match if !defined($n)
  when (undef) {
    say '$n is undefined';
  }
# match if $n eq "foo"
  when ("foo") {
    say '$n is the string "foo"';
  }
# match if $n ~~ [1,3,5,7,9]
  when ([1,3,5,7,9]) {
    say '$n is an odd digit';
  continue; # Fall through!!
  }
# match if $n < 100
  when ($_ < 100) {
    say '$n is numerically less than 100';
  }
# match if complicated_check($n)
  when (\&complicated_check) {
    say 'a complicated check for $n is true';
  }
# match if no other cases match
  default {
    die q(I don't know what to do with $n);
  }
}

my $price = do {
  given ($item) {
    when (["pear", "apple"]) { 1 }
    break when "vote";
# My vote cannot be bought
    1e10 when /Mona Lisa/;
    "unknown";
  }
};
