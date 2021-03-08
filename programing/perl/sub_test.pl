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

