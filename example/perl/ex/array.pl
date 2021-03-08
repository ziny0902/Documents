#!/usr/bin/perl
#
use v5.32.0;

my @ages =(25, 30, 40);
my @names = ("John Paul", "Lisa", "Kumar");

print "\$ages[0] = $ages[0]\n";
print "\$ages[1] = $ages[1]\n";
print "\$ages[2] = $ages[2]\n";
print "\$names[0] = $names[0]\n";
print "\$names[1] = $names[1]\n";
print "\$names[2] = $names[2]\n";

print "\n";

my @days = qw/Mon Tue Wed Thu Fri Sat Sun/;

print "$days[0]\n";
print "$days[1]\n";
print "$days[2]\n";
print "$days[6]\n";
print "$days[-1]\n";
print "$days[-7]\n";

print "\n";

my @var_10 = (1...10);
my @var_20 = (10...20);
my @var_abc = ('a'..'z');

print "@var_10\n";
print "@var_20\n";
print "@var_abc\n";
print "\@var_10 Size: ", scalar @var_10, "\n";
my $size = @var_10;
my $max_index = $#var_10;

print "Size: $size\n";
print "Max Index: $max_index\n";

print "\n";

my @coins = ("Quarter", "Dim", "Nickel");
print "1. \@coins = @coins\n";

push(@coins, "Penny");
print "2. \@coins = @coins\n";

unshift(@coins, "Dollar");
print "3. \@coins = @coins\n";

pop(@coins);
print "4. \@coins = @coins\n";

shift(@coins);
print "5. \@coins = @coins\n";

print "\n";

my @weekdays = @days[3,4,5];
print "@weekdays\n";
my @weekdays = @days[3..5];
print "@weekdays\n";

print "\n";

my @nums = (1..20);
print "Before - @nums\n";

splice(@nums, 5, 5, 21..25);
print "After - @nums\n";

print "\n";

# define Strings
my $var_string = "Rain-Drops-On-Roses-And-Whiskers-On-Kittens";
my $var_names = "Larry,David,Roger,Ken,Michael,Tom";

# transform above strings into arrays.
my @string = split('-', $var_string);
my @name = split(',', $var_names);

print "$string[3]\n";
print "$name[4]\n";

print "\n";

my $string1 = join('-', @string);
my $string2 = join(',', @names);

print "$string1\n";
print "$string2\n";

my @names = sort(@names);
my @string = sort(@string);

print "After: @string\n";
print "After: @names\n";

print "\n";

my @numbers = (1, 3,(4,5,6));
print "numbers = @numbers\n";

for my $num (@numbers) {
  say "for ", $num;
}

foreach my $num (@numbers){
  say "foreach ", $num;
}

for (@numbers){
  say "\$_ ", $_;
}

my @sp_num = @numbers[0,  3]; # select 1, 5
my @sp_num = @numbers[0 .. 3]; # select 1, 3, 4, 5
say "split array: ", @sp_num;
for (@sp_num){
  say "\$_ ", $_;
}

my $arr_len = scalar @numbers;
say "array length: ", $arr_len;

my ($a, $b, $c) = @numbers;
say "variable assign ", $a, " ", $b;

say "Popped Value ", pop @numbers;
say "Pushed Value ", push @numbers, 17;
say "First Item ", shift @numbers;
say "Unshifted Item ", unshift @numbers, 2;
print join(", ", @numbers), "\n";
say "Remove Index 0 - 2: ", splice @numbers, 0, 3;

my $customers = "Sue Sally Paul";
my @cust_array = split / /, $customers;
print join(", ", @cust_array), "\n";

@cust_array = reverse @cust_array;
@cust_array = reverse sort @cust_array;
my @number_array = (1 .. 8);
my @odds_array = grep {$_ % 2} @number_array;
print join(", ", @odds_array), "\n";

my @dl_array = map {$_ * 2} @number_array;
print "double array: ", join(", ", @dl_array), "\n";

# hash

my %employees = (
  "sue" => 35,
  "paul" => 43,
  "sam" => 39
);

printf("Sue is %d \n", $employees{sue});

$employees{Frank} = 44;

while (my ($k, $v) = each %employees) {
  print "$k $v \n"
}

my @ages = @employees {"sue", "sam" };
say @ages;

my @hash_array = %employees;
delete $employees{'Frank'};


while (my ($k, $v) = each %employees) {
  print "$k $v \n"
}

say ((exists $employees{'sam'}) ? "Sam is here" : "No Sam");

for my $key (keys %employees){
  if($employees{$key} == 35) {
    say "Hi Sue";
  }
}



my @odd = (1,3,5);
my @even = (2,4,6);

my @numbers = (@odd, @even);

print "numbers = @numbers\n";

print "\n";

my $var = (5,4,3,2,1)[4];
print "value of var = $var\n";

my @list = (5,4,3,2,1)[1..3];
print "Value of list = @list\n";
