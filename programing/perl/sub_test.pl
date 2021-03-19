#!/usr/bin/perl -I.
use 5.32.0;

use AST;
use Scanner;


my $fname = "test.lua";

open( my $fh, "< :encoding(UTF-8)", $fname )
    || die "$0: can't open $fname for reading: $!";
my %keywords =(
      "and" => 1,
      "break" => 1,
      "do" => 1,
      "else" => 1,
      "elseif" => 1,
      "end" => 1,
      "false" => 1,
      "for" => 1,
      "function" => 1,
      "if" => 1,
      "in" => 1,
      "local" => 1,
      "nil" => 1,
      "not" => 1,
      "or" => 1,
      "repeat" => 1,
      "return" => 1,
      "then" => 1,
      "true" => 1,
      "until" => 1,
      "while" => 1,
      "goto" => 1,
    );
my %mlength_op = (
    "..." => 1,
    ".." => 1,
    ">=" => 1,
    "<=" => 1,
    "==" => 1,
    "~=" => 1,
    "//" => 1,
    "::" => 1,
);

my @quote_unquote_seq = (
  {
    quote => "[[",
    unquote => "]]"
  },
  {
    quote => "\"",
    unquote => "\""
  },
  {
    quote => "'",
    unquote => "'"
  },
);

my $scanner = Scanner->new( 
  { 
    fh=>$fh, 
    keywords => \%keywords,
    mlength_op => \%mlength_op,
    qq_unqqs => \@quote_unquote_seq,
    lcomment => "--",
    bcomment_s => "--[[",
    bcomment_e => "--]]",
  } );
my $token;

while ( $token = $scanner->getToken() ){
  print $$token{name}." ".$$token{value}."\n";
}


#sub ast_tree_dump {
#  my $root = shift(@_);
#  my $prefix = shift( @_ );
#  print $prefix . ${$root}{name} . "\n ";
#  for my $child( @{${$root}{child}} ){
#    ast_tree_dump( $child, $prefix . "  "  );
#  }
#}
#
#my $root = AST::create_node("root", "");
#my $child = AST::create_node( "leaf0", "" );
#AST::add_child_by_path( $root, $child, "child/grand_child0" );
#$child = AST::create_node( "leaf1", "" );
#AST::add_child_by_path( $root, $child, "child/grand_child1" );
#$child = AST::create_node( "grand child", "" );
#AST::add_child_by_path( $root, $child, "child" );
#$child = AST::create_node( "leaf", "" );
#AST::add_child_by_path( $root, $child, "child/grand child#2" );
#AST::add_child_by_path( $root, $child, "child/grand child#0" );
#ast_tree_dump( $root, "" );
#$child = AST::get_child( $root, "child/grand_child1" );
#$child = AST::get_child( $child, "../grand child#2" );
#print "\n\n\n=========\n";
#ast_tree_dump( $child, "" );
#print "\n\n\n=========\n";
#AST::dump( $root, 2 );
#
#
#
#my @c = ( 1, 2, 3, 4 );
#my @d = ( 1, 2, 3, 4, 5, 6, 7, 8 );
#
#sub func {
#  my ($cref, $dref) = @_;
#  if ( @{$cref} > @{$dref} ) {
#    return ($cref, $dref);
#  } else {
#    return ($dref, $cref);
#  }
#}
#
#my ($aref, $bref) = func(\@c, \@d);
#print "@{$aref} has more than @{$bref}\n";
#
#my @arr = ();
#push( @arr, ["string1", [1, 2]] );
#push( @arr, ["string2", [3, 4]] );
#push( @arr, ["string3", [5, 6]] );
#push( @arr, ["string4", [7, 8]] );
#print @{$arr[1]};
#print "\n";
#print ${$arr[1]}[0] . "\n";
#print @{${$arr[1]}[1]};
#print "\n";
#
#my $size = @arr;
#print $size;
#print "\n";
#
#print $#arr;
#print "\n";
#
#my %hash = (
#);
#
#push ( @{$hash{a}}, 1 );
#push ( @{$hash{a}}, 2 );
#push ( @{$hash{a}}, 3 );
#push ( @{$hash{a}}, 4 );
#push ( @{$hash{b}}, 5 );
#push ( @{$hash{c}}, 6 );
#push ( @{$hash{b}}, 7 );
##push ( ${$hash}{a}, 2 );
##push ( ${$hash}{a}, 3 );
##push ( ${$hash}{b}, 4 );
##push ( ${$hash}{c}, 5 );
##push ( ${$hash}{c}, 6 );
#
#my $hash_arr = $hash{a};
#print @$hash_arr;
#print "\n";
#
#my $str = "\" adsfads \"";
#$str =~ s/"/\\"/g;
#print $str . "\n";
