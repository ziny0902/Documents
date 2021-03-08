#!/usr/bin/perl
#
use v5.14;

print "What is your favorite color? ";
chomp(my $answer = <STDIN>);

given ($answer) {
    when ("purple") { say "Me too."; }
    when ("green") { say "Go!"; }
    when ("yellow") { say "Slow!"; }
    when ("red") { say "Stop!"; }
    when ("blue") { say "you may proceed."; }
    when (/\w+, no \w+/) { die "AAAUUUQHHHH!"; }
    when (42) { say "Wrong answer."; }
    when (['gray', 'orange', 'brown', 'black', 'white']) {
      say "I think $answer is pretty okay too."; 
    }
    default {
      say "Are you sure $answer is a real color?"; 
    }
}
