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

sub add_child_by_path{
  my $root = shift;
  my $child = shift;
  my $path = shift;
  my $target_root = create_path( $root, $path );
  add_child( $target_root, $child );
}

sub create_path{
  my $root = shift;
  my $path = shift;
  my @as = split(/\//, $path);
  for my $node_name ( @as ){
    my @arr = split(/#/, $node_name);
    my $name = shift( @arr );
    my $idx = shift( @arr );
    $idx = 0 unless $idx;
    my $i = -1;
    my $target_node = undef;
    for my $node ( @{${$root}{child}} ){
      if( ${$node}{name} eq $name ){
        $i++;
        if($i == $idx){
          $target_node = $node;
          last;
        }
      }
    }
    unless( $target_node ){
      my $child;
      for ( ; $i < $idx; $i++ ){
        $child = create_node( $name, "" );
        add_child( $root, $child );
      }
      $root = $child;
      next;
    }
    $root = $target_node;
  }
  return $root;
}

sub get_child{
  my $root = shift;
  my $path = shift;
  my @as = split(/\//, $path);
  for my $node_name ( @as ){
    my $target_node = undef;
    my @arr = split(/#/, $node_name);
    my $name = shift( @arr );
    my $idx = shift( @arr );
    $idx = 0 unless $idx;
    my $i = -1;
    for $node ( @{${$root}{child}} ){
      if( ${$node}{name} eq $name ){
        $i++;
        if( $i == $idx ){
          $target_node= $node;
          last;
        }
      }
    }
    return undef unless $target_node; # there wasn't a matching child.
    $root = $target_node;
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
