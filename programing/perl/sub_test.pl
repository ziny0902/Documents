use 5.32.0;

my @c = ( 1, 2, 3, 4 );
my @d = ( 1, 2, 3, 4, 5, 6, 7, 8 );

sub func {
  my ($cref, $dref) = @_;
  if ( @{$cref} > @{$dref} ) {
    return ($cref, $dref);
  } else {
    return ($dref, $cref);
  }
}

my ($aref, $bref) = func(\@c, \@d);
print "@{$aref} has more than @{$bref}\n";

my @arr = ();
push( @arr, ["string1", [1, 2]] );
push( @arr, ["string2", [3, 4]] );
push( @arr, ["string3", [5, 6]] );
push( @arr, ["string4", [7, 8]] );
print @{$arr[1]};
print "\n";
print ${$arr[1]}[0] . "\n";
print @{${$arr[1]}[1]};
print "\n";

my $size = @arr;
print $size;
print "\n";

print $#arr;
print "\n";

my %hash = (
);

push ( @{$hash{a}}, 1 );
push ( @{$hash{a}}, 2 );
push ( @{$hash{a}}, 3 );
push ( @{$hash{a}}, 4 );
push ( @{$hash{b}}, 5 );
push ( @{$hash{c}}, 6 );
push ( @{$hash{b}}, 7 );
#push ( ${$hash}{a}, 2 );
#push ( ${$hash}{a}, 3 );
#push ( ${$hash}{b}, 4 );
#push ( ${$hash}{c}, 5 );
#push ( ${$hash}{c}, 6 );

my $hash_arr = $hash{a};
print @$hash_arr;
print "\n";
