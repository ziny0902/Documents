# from perldata
# perldoc perldata

$days               # the simple scalar value "days"
$days[28]           # the 29th element of array @days
$days{'Feb'}        # the 'Feb' value from hash %days
$#days              # the last index of array @days


@days               # ($days[0], $days[1],... $days[n])
@days[3,4,5]        # same as ($days[3],$days[4],$days[5])
@days{'a','c'}      # same as ($days{'a'},$days{'c'})


%map = ('red',0x00f,'blue',0x0f0,'green',0xf00);
%map = (
      red   => 0x00f,
      blue  => 0x0f0,
      green => 0xf00,
);


$rec = {
        witch => 'Mable the Merciless',
        cat   => 'Fluffy the Ferocious',
        date  => '10/31/1776',
};


$field = $query->radio_group(
           name      => 'group_name',
           values    => ['eenie','meenie','minie'],
           default   => 'meenie',
           linebreak => 'true',
           labels    => \%labels
       );


%circle = (
              center => [5, 10],
              center => [27, 9],
              radius => 100,
              color => [0xDF, 0xFF, 0x00],
              radius => 54,
);

# same as
%circle = (
              center => [27, 9],
              color => [0xDF, 0xFF, 0x00],
              radius => 54,
);


@myarray = (5, 50, 500, 5000);
        print "The Third Element is", $myarray[2], "\n";


%scientists =
        (
            "Newton" => "Isaac",
            "Einstein" => "Albert",
            "Darwin" => "Charles",
            "Feynman" => "Richard",
        );
print "Darwin's First Name is ", $scientists{"Darwin"}, "\n";

# You can also subscript a list to get a single element from it:
$dir = (getpwnam("daemon"))[7];

$foo{$x,$y,$z}
#is equivalent to
$foo{join($;, $x, $y, $z)}

($him, $her)   = @folks[0,-1];              # array slice
@them          = @folks[0 .. 3];            # array slice
($who, $home)  = @ENV{"USER", "HOME"};      # hash slice
($uid, $dir)   = (getpwnam("daemon"))[2,7]; # list slice
# The previous assignments are exactly equivalent to
($days[3], $days[4], $days[5]) = qw/Wed Thu Fri/;
($colors{'red'}, $colors{'blue'}, $colors{'green'})
               = (0xff0000, 0x0000ff, 0x00ff00);
($folks[0], $folks[-1]) = ($folks[-1], $folks[0]);


$Price = '$100';    # not interpolated
print "The price is $Price.\n";     # interpolated

$who = "Larry";
print PASSWD "${who}::0:0:Superuser:/:/bin/perl\n";
print "We use ${who}speak when ${who}'s here.\n";

#Numeric literals
#12345
#12345.67
#.23E-10             # a very small number
#3.14_15_92          # a very important number
#4_294_967_296       # underscore for legibility
#0xff                # hex
#0xdead_beef         # more hex
#0377                # octal (only numbers, begins with 0)
#0b011011            # binary
#0x1.999ap-4         # hexadecimal floating point (the 'p' is required)

# Stat returns list value.
$time = (stat($file))[8];

# SYNTAX ERROR HERE.
$time = stat($file)[8];  # OOPS, FORGOT PARENTHESES

# Find a hex digit.
$hexdigit = ('a','b','c','d','e','f')[$digit-10];

# A "reverse comma operator".
return (pop(@foo),pop(@foo))[0];

($x, $y, $z) = (1, 2, 3);

($map{'red'}, $map{'blue'}, $map{'green'}) = (0x00f, 0x0f0, 0xf00);

($dev, $ino, undef, undef, $uid, $gid) = stat($file);


use warnings;
my (@xyz, $x, $y, $z);

@xyz = (1, 2, 3);
print "@xyz\n";                             # 1 2 3

@xyz = ('al', 'be', 'ga', 'de');
print "@xyz\n";                             # al be ga de

@xyz = (101, 102);
print "@xyz\n";                             # 101 102


($x, $y, $z) = (1, 2, 3);
print "$x $y $z\n";                         # 1 2 3

($x, $y, $z) = ('al', 'be', 'ga', 'de');
print "$x $y $z\n";                         # al be ga

($x, $y, $z) = (101, 102);
print "$x $y $z\n";                         # 101 102
# Use of uninitialized value $z in concatenation (.)
# or string at [program] line [line number].


($x, $y, $z) = (101, 102);
for my $el ($x, $y, $z) {
    (defined $el) ? print "$el " : print "<undef>";
}
print "\n";
                                            # 101 102 <undef>
$x = (($foo,$bar) = (3,2,1));       # set $x to 3, not 2
$x = (($foo,$bar) = f());           # set $x to f()'s return count

$count = () = $string =~ /\d+/g;
# will place into $count the number of digit groups found in $string.
#
$count = $string =~ /\d+/g;
# would not have worked, since a pattern match in scalar context will only
# return true or false, rather than a count of matches.

($x, $y, @rest) = split;
my($x, $y, %rest) = @_;
# You can actually put an array or hash anywhere in the list, but the
# first one in the list will soak up all the values, and anything after it
# will become undefined. This may be useful in a my() or local().


@a = qw/first second third/;
%h = (first => 'A', second => 'B');
$t = @a[0, 1];                  # $t is now 'second'
$u = @h{'first', 'second'};     # $u is now 'B'

%h = (blonk => 2, foo => 3, squink => 5, bar => 8);
%subset = %h{'foo', 'bar'}; # key/value hash slice
# %subset is now (foo => 3, bar => 8)
%removed = delete %h{'foo', 'bar'};
# %removed is now (foo => 3, bar => 8)
# %h is now (blonk => 2, squink => 5)

@a = "a".."z";
@list = %a[3,4,6];
# @list is now (3, "d", 4, "e", 6, "g")
@removed = delete %a[3,4,6]
# @removed is now (3, "d", 4, "e", 6, "g")
# @list[3,4,6] are now undef


