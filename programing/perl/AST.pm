package AST;

sub create_node {
  my $name = shift( @_ );
  my $value = shift( @_ );
  my @arr = ();
  my %root = (
    child => \@arr,
    name => $name,
    value => $value,
    line => 0,
  );
  return \%root;
}

sub add_child {
  my $root = shift( @_ );
  my $child_node = shift( @_ );
  push ( @{ ${$root}{child} }, $child_node );
  ${$child_node}{parent} = $root;
} 

sub get_child{
  my $root = shift;
  my $path = shift;
  my @as = split(/\//, $path);
  my $node ;
  for my $node_name ( @as ){
    my @arr = split(/#/, $node_name);
    my $name = shift( @arr );
    my $idx = shift( @arr );
    $idx = 0 unless $idx;
    my $i = -1;
    for $node ( @{${$root}{child}} ){
      if( ${$node}{name} eq $name ){
        $root = $node;
        $i++;
        last if $i == $idx;
      }
    }
    return undef unless ${$root}{name} eq $name; # there wasn't a matching child.
  }
  return $root;
}

sub add_neighbor {
  my $self = shift( @_ );
  my $child_node = shift( @_ );
  push ( @{ ${${$self}{parent}}{child} }, $child_node );
  ${$child_node}{parent} = ${$self}{parent};
}

1
