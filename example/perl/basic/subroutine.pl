sub max {
  my $max = shift(@_);
  foreach $foo (@_) {
    $max = $foo if $max < $foo;
  }
  return $max;
}
$bestday = max($mon,$tue,$wed,$thu,$fri);

sub maybeset {
  my($key, $value) = @_;
  $Foo{$key} = $value unless $Foo{$key};
}

($v3, $v4) = upcase($v1, $v2);  # this doesn't change $v1 and $v2
sub upcase {
    return unless defined wantarray;  # void context, do nothing
    my @parms = @_;
    for (@parms) { tr/a-z/A-Z/ }
    return wantarray ? @parms : $parms[0];
}
thefunc(INCREMENT => "20s", START => "+5m", FINISH => "+30m");
thefunc(START => "+5m", FINISH => "+30m");
thefunc(FINISH => "+30m");
thefunc(START => "+5m", INCREMENT => "15s");
sub thefunc {
  my %args = (
    INCREMENT => "10s",
    FINISH
    => 0,
    START
    => 0,
    @_, # actual args override defaults
  );
  if ($args{INCREMENT} =~ /m$/ ) { ... }
  ...
}

@c = ( 1, 2, 3, 4 );
@d = ( 1, 2, 3, 4, 5, 6, 7, 8 );

sub func {
  my ($cref, $dref) = @_;
  if ( @{$cref} > @{$dref} ) {
    return ($cref, $dref);
  } else {
    return ($dref, $cref);
  }
}

($aref, $bref) = func(\@c, \@d);
print "@{$aref} has more than @{$bref}\n";
