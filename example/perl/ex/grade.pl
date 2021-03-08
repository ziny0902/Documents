#!/usr/bin/perl
#
open(GRADE, "<:utf8", "grade") ||  die "Can't open grades: $!\n";
binmode(STDOUT, ':utf8');

my %grades;

while (my $line = <GRADE>){
  my ($student, $grade) = split(" ", $line);
  $grades{$student} .= $grade . " ";
}

for my $student (sort keys %grades) {
  my $scores = 0;
  my $total = 0;
  my @grades = split(" ", $grades{$student});
  for my $grade (@grades) {
    $total += $grade;
    $scores++;
  }
  my $average = $total / $scores;
  print "$student: $grades{$student}\tAverage: $average\n";
}
