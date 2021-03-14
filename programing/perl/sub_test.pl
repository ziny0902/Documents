#!/usr/bin/perl -I.
use 5.32.0;

use AST;

sub ast_tree_dump {
  my $root = shift(@_);
  my $prefix = shift( @_ );
  print $prefix . ${$root}{name} . "\n ";
  for my $child( @{${$root}{child}} ){
    ast_tree_dump( $child, $prefix . "  "  );
  }
}

my $root = AST::create_node("root", "");
my $child = AST::create_node( "leaf0", "" );
AST::add_child_by_path( $root, $child, "child/grand_child0" );
$child = AST::create_node( "leaf1", "" );
AST::add_child_by_path( $root, $child, "child/grand_child1" );
$child = AST::create_node( "grand child", "" );
AST::add_child_by_path( $root, $child, "child" );
$child = AST::create_node( "leaf", "" );
AST::add_child_by_path( $root, $child, "child/grand child#2" );
AST::add_child_by_path( $root, $child, "child/grand child#0" );
ast_tree_dump( $root, "" );


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

my $str = "\" adsfads \"";
$str =~ s/"/\\"/g;
print $str . "\n";
