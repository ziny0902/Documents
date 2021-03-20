package AST;

sub new{
  my ($class, $args) = @_;
  my $self = bless {
            rop_map => $args->{rop_map},
            unary_op => $args->{unary_op},
            biop_priority => $args->{biop_priority},
            unary_priority => $args->{unary_priority},
            }, $class;
}

sub add_child {
  my $self = shift;
  my $root = shift( @_ );
  my $child_node = shift( @_ );
  push ( @{ ${$root}{child} }, $child_node );
  ${$child_node}{parent} = $root;
} 

sub get_priority{
  my $self = shift;
  my $operator = shift;
  my $biop_priority = $self->{biop_priority};
  my $unary_priority = $self->{unary_priority};
  my $num_of_operand = $#{$operator->{child}} + 1;
  my $op = ${$operator}{value};
  if( $num_of_operand == 1){ #unary op
    my $priority = $unary_priority->{$op};
    return $priority if defined $priority;
  }
  my $priority = $biop_priority->{$op};
  return $priority if defined $priority;
  return 10; 
}

sub left_op{
  my $self = shift;
  my $operands = shift;
  my $op = shift;
  my $left = shift;
  my $right = shift;

  my $lop_priority = $self->get_priority( $left );
  my $op_priority = $self->get_priority( $op );
  if( $lop_priority < $op_priority ) {
    my $lr = pop( @{${$left}{child}} );
    my $ll = pop( @{${$left}{child}} );
    $self->add_exp_node( $op, $lr, $right );
    if( $ll ) {
      $self->add_exp_node( $left, $ll, $op );
    }else {
      $self->add_child( $left, $op );
    }
    unshift( @$operands, $left );
  }else {
    $self->add_exp_node( $op, $left, $right);
    unshift( @$operands, $op );
  }
}

sub right_op{
  my $self = shift;
  my $operators= shift;
  my $operands = shift;
  my $rop_map = $self->{rop_map};

  my $op = shift( @$operators );
  my $left = shift( @$operands );
  if( $#{$operators} >= 0 && $rop_map->{${${$operators}[0]}{value}} ) {
    $self->right_op( $operators, $operands );
  }
  my $right = shift( @$operands );
  $self->left_op( $operands, $op, $left, $right );
}

sub rearrange_ast2exp{
  my $self = shift;
  my $root = shift;
  my $childs = ${$root}{child};
  my @operands = ();
  my @operators = ();
  my $num = $#{$childs};
  my $rop_map = $self->{rop_map};
  my $unary_op = $self->{unary_op};
  for( $i=0; $i <= $num; $i++ ){
    if( $i%2 == 0 ) {
      my $operand = shift( @$childs );
      if( $unary_op->{${$operand}{value}} ) {
        $self->add_child( $operand, shift( @$childs ) );
        $num--;
      }
      push( @operands,  $operand );
    }else {
      push( @operators, shift( @$childs ) );
    }
  }
  while( my $operator = shift( @operators )  ) {
    if( $rop_map->{$operator{value}} ){
      $self->right_op( \@operators, \@operands );
    }
    my $left = shift( @operands );
    if( $#operators >= 0 && $rop_map->{${$operators[0]}{value}} ){
      $self->right_op( \@operators, \@operands );
    }
    my $right = shift( @operands );
    $self->left_op( \@operands, $operator, $left, $right); 
  }
  $self->add_child( $root, shift( @operands ) );
}

sub add_exp_node{
  my $self = shift;
  my $operator = shift;
  my $left = shift;
  my $right = shift;

  $self->add_child( $operator, $left );
  $self->add_child( $operator, $right );
}

sub add_child_by_path{
  my $self = shift;
  my $root = shift;
  my $child = shift;
  my $path = shift;
  my $target_root = $self->create_path( $root, $path );
  $self->add_child( $target_root, $child );
}

sub create_path{
  my $self = shift;
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
        $self->add_child( $root, $child );
      }
      $root = $child;
      next;
    }
    $root = $target_node;
  }
  return $root;
}

sub get_child{
  my $self = shift;
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
  my $self = shift;
  my $node = shift( @_ );
  my $child_node = shift( @_ );
  push ( @{ ${${$node}{parent}}{child} }, $child_node );
  ${$child_node}{parent} = ${$node}{parent};
}

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

sub dump_hash{
  my $hash = shift;
  my $indent_str = shift;
  my $indent = shift;
  my @keys = sort( keys %{$hash} );
  for( $i = 0; $i < $indent; $i++ ) {
    $indent_str = $indent_str . " ";
  }
  print $indent_str . "{\n";
  my @nested_keys = ();
  my @nested_vals = ();
  while (@keys) {
    my $key = shift( @keys );
    my $val = ${$hash}{$key};
    next if ( $key eq "parent" );
    my $type = ref( $val ); 
    if( $type eq "HASH" ){
      push( @nested_keys, $key );
      push( @nested_vals, $val );
    }elsif( $type eq "ARRAY" ){
      push( @nested_keys, $key );
      push( @nested_vals, $val );
    }else {
      print $indent_str . $key . " :" . $val . "\n";
    }
  }
  while( @nested_keys ){
    my $val = shift( @nested_vals );
    my $key = shift( @nested_keys );
    my $type = ref( $val ); 
    if( $type eq "HASH" ){
      print $indent_str . $key . " :\n";
      dump_hash( $val, $indent_str, $indent );
    }elsif( $type eq "ARRAY" ){
      print $indent_str . $key . " :\n";
      dump_array( $val, $indent_str, $indent );
    }
  }
  print $indent_str . "}\n"
}

sub dump_array{
  my $arr = shift;
  my $indent_str = shift;
  my $indent = shift;
  return if $#{$arr} < 0;
  for( $i = 0; $i < $indent; $i++ ) {
    $indent_str = $indent_str . " ";
  }
  print $indent_str . "[\n";
  while( @$arr ){
    my $val = shift( @$arr );
    my $type = ref( $val );
    if( $type eq "HASH" ){
      dump_hash( $val, $indent_str, $indent );
    }elsif( $type eq "ARRAY" ){
      dump_arr( $val, $indent_str, $indent );
    }else {
      print $indent_str . $val . "\n";
    }
  }
  print $indent_str . "]\n";
}

sub dump {
  my $node = shift;
  my $indent = shift;

  dump_hash( $node, "", $indent);
}

1
