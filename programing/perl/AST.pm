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

my %rop_map = (
  "^" => 1,
  ".." => 1,
);

my %unary_op = (
  "-" => 1,
  "not" => 1,
  "#" => 1,
);

sub get_priority{
  my $operator = shift;
  my $op = ${$operator}{value};
  if( $op eq '^' ) {
    return 7;
  }
  if( $op eq '-' && $#{${$operator}{child}} == 0){
    return 6;
  }
  if( $op eq 'not' || $op eq "#") {
    return 6;
  }
  if( $op =~ /[\/\*]/ ) {
    return 5;
  }
  if( $op =~ /[\+-]/ ) {
    return 4;
  }
  if( $op eq '..' ) {
    return 3;
  }
  if( $op eq '<' ) {
    return 2;
  }
  if( $op eq '<=' ) {
    return 2;
  }
  if( $op eq '>' ) {
    return 2;
  }
  if( $op eq '>=' ) {
    return 2;
  }
  if( $op eq '==' ) {
    return 2;
  }
  if( $op eq '~=' ) {
    return 2;
  }
  if( $op eq 'and') {
    return 1;
  }
  if( $op eq 'or' ) {
    return 0;
  }
  return 10 
}

sub left_op{
  my $operands = shift;
  my $op = shift;
  my $left = shift;
  my $right = shift;

  my $lop_priority = get_priority( $left );
  my $op_priority = get_priority( $op );
  if( $lop_priority < $op_priority ) {
    my $lr = pop( @{${$left}{child}} );
    my $ll = pop( @{${$left}{child}} );
    add_exp_node( $op, $lr, $right );
    #add_exp_node( $left, $ll, $op );
    if( $ll ) {
      add_exp_node( $left, $ll, $op );
    }else {
      add_child( $left, $op );
    }
    unshift( @$operands, $left );
  }else {
    add_exp_node( $op, $left, $right);
    unshift( @$operands, $op );
  }
}


sub right_op{
  my $operators= shift;
  my $operands = shift;

  my $op = shift( @$operators );
  my $left = shift( @$operands );
  if( $#{$operators} >= 0 && $rop_map{${${$operators}[0]}{value}} ) {
    right_op( $operators, $operands );
  }
  my $right = shift( @$operands );
  left_op( $operands, $op, $left, $right );
}

sub rearrange_ast2exp{
  my $root = shift;
  my $childs = ${$root}{child};
  my @operands = ();
  my @operators = ();
  my $num = $#{$childs};
  for( $i=0; $i <= $num; $i++ ){
    if( $i%2 == 0 ) {
      my $operand = shift( @$childs );
      if( $unary_op{${$operand}{value}} ) {
        add_child( $operand, shift( @$childs ) );
        $num--;
      }
      push( @operands,  $operand );
    }else {
      push( @operators, shift( @$childs ) );
    }
  }
  while( my $operator = shift( @operators )  ) {
    if( $rop_map{$operator{value}} ){
      right_op( \@operators, \@operands );
    }
    my $left = shift( @operands );
    if( $#operators >= 0 && $rop_map{${$operators[0]}{value}} ){
      right_op( \@operators, \@operands );
    }
    my $right = shift( @operands );
    left_op( \@operands, $operator, $left, $right); 
  }
  add_child( $root, shift( @operands ) );
}

sub add_exp_node{
  my $operator = shift;
  my $left = shift;
  my $right = shift;

  add_child( $operator, $left );
  add_child( $operator, $right );
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
    if ( $name eq ".." ) {
      $root = ${$root}{parent};
      next;
    }
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
