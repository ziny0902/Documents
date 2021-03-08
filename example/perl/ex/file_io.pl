#!/usr/bin/perl

use v5.32.0;

my $emp_file = 'emploees.data';

open my $fh, '<', $emp_file
  or die "Can't Open File : $_";

while(my $info = <$fh>) {
  chomp($info);

  my ($emp_name, $job, $id) = split /:/, $info;

  print "$emp_name is a $job and has the id $id \n";

}

close $fh or die "Couldn't Close File : $_";

open $fh, ">>", $emp_file
  or die "Can't Open File : $_";

print $fh "DD:Salesman:130\n";
close $fh or die "Couldn't Close File : $_";

open $fh, "+<", $emp_file
  or die "Can't Open File : $_";

seek $fh, 0, 0;


print $fh "Phil:Salesman:125\n";
close $fh or die "Couldn't Close File : $_";
