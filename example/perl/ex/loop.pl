#!/usr/bin/perl

use v5.32.0;

use feature "switch";

# for loop
for(my $i = 0; $i < 10; $i++){
  say $i;
}

my $i = 1;

# while, next, last
while($i < 10) {
  if($i %2 == 0){
    $i++;

    next;
  }
  if($i == 7){last;}
  say $i;
  $i++;
}

my $lucky_num = 7;
my $guess;
do {
  say "Guess a Number Between 1 and 10";

  $guess = <STDIN>;
} while $guess != $lucky_num;

say "You Guessed 7";

my $age_old = 18;

given($age_old){
  when($_ > 16){
    say "Drive";
    continue;
  }
  when($_ > 17) {say "Go Vote";}
  default {say "Nothing Special";}
}
