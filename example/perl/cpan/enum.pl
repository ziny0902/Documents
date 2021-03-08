use enum qw(
    :Months_=0 Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
    :Days_=0   Sun Mon Tue Wed Thu Fri Sat
    :LC_=0     Sec Min Hour MDay Mon Year WDay YDay Isdst
);
 
if ((localtime)[LC_Mon] == Months_Feb) {
    print "It's February!\n";
}
if ((localtime)[LC_WDay] == Days_Sun) {
    print "It's Sunday!\n";
}

use enum qw(BITMASK: MY_ FOO BAR CAT DOG);
 
my $foo = 0;
$foo |= MY_FOO;
$foo |= MY_DOG;
 
if ($foo & MY_DOG) {
    print "foo has the MY_DOG option set\n";
}
if ($foo & (MY_BAR | MY_DOG)) {
    print "foo has either the MY_BAR or MY_DOG option set\n"
}
 
$foo ^= MY_DOG;  ## Turn MY_DOG option off (set its bit to false)
