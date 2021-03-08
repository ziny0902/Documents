# TODO : implement tree func
# structure : val, child
# Tree add
# Tree traverse
# Tree delete

use 5.32.0;

sub create_node {
  my $name = shift( @_ );
  my $value = shift( @_ );
  my @arr = ();
  my %root = (
    child => \@arr,
    name => $name,
    value => $value,
  );
  return \%root;
}

sub add_child {
  my $root = shift( @_ );
  my $child_node = shift( @_ );
  push ( @{ ${$root}{child} }, $child_node );
  ${$child_node}{parent} = $root;
} 

sub add_neighbor {
  my $self = shift( @_ );
  my $child_node = shift( @_ );
  push ( @{ ${${$self}{parent}}{child} }, $child_node );
  ${$child_node}{parent} = ${$self}{parent};
}

sub ats_Add_child{
  my $parser = shift(@_);
  my $state = shift(@_);
  my $root = ${$parser}{root};
  my $tokens = ${$parser}{tokens};
  my @dummy = ();
  ${$parser}{tokens} = \@dummy;
  my $child = create_node ( "node", $tokens);
  add_child( $root, $child ); 
  return $child;
}

sub tree_dump {
  my $root = shift(@_);
  my $prefix = shift(@_);
  print $prefix . ${$root}{name} . " " . ${$root}{value} . "\n";
  for my $child( @{${$root}{child}} ){
    tree_dump( $child, $prefix . "  "  );
  }
}

my $root = create_node( "script", "");
my $node = create_node( "node", "root->node");
add_child( $root, $node );
my $neighbor = create_node( "node", "root->node2");
add_neighbor( $node, $neighbor);
my $child = create_node( "node", "root->node3");
add_neighbor( $neighbor, $child );
$child = create_node( "node", "root->node->node1");
add_child( $node, $child);
$child = create_node( "node", "root->node->node2");
add_child( $node, $child);
$child = create_node( "node", "root->node->node3");
add_child( $node, $child);
$node = $child;
$child = create_node( "node", "root->node->node3->node1");
add_child( $node, $child);

tree_dump( $root, "" );

my @arr = (
  [0, 1, 2, 3],
  4, 5,6
);

print @{$arr[0]};
print "\n";

foreach my $num (@{$arr[0]}) {
    print $num . " ";
}
print "\n";



#my @root = ( 
#{
#  sentence => {
#    ""     => 'I saw a dog',
#    noun   => {
#        "" => 'I',
#    },
#    verb   => {
#        "" => 'saw',
#    },
#    object => {
#        ""      => 'a dog',
#        article => {
#            "" => 'a',
#        },
#        noun    => {
#            "" => 'dog',
#        },
#    },
#  }
#} 
#);
#
#sub tree_dump{
#  my $hash = shift(@_);
#  my $prefix = shift(@_);
#  my @k = keys %{$hash};
#  for my $key (@k) {
#    next if $key eq "";
#    print "${prefix}\[$key\]\n";
#    tree_dump( \%{ %$hash{$key} }, $prefix . "  " );
#  }
#}
#
#for my $key (@root) {
#  tree_dump($key, "");
#}
my @arr=(1, 2, 3, 4);
my %table = ( 
  arr => \@arr, 
  line => 1,
);
my $parr = $table{arr};
my $table_ref = \%table;

print shift(@$parr) . "\n";
print shift(@$parr) . "\n";

${$table_ref}{line} = 2;

$table{line} = $table{line} + 5;
print $table{line};

