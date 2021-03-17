#!/usr/bin/perl -I.
use 5.32.0;

use enum qw(
    :Parser_=0 Stat Name Namelist Prefixexp Varlist Var Args Exp  
    Explist Assignment Function Functioncall Tableconstructor Local 
    Field Transition If Do While Repeat For Break Funcbody
    Paralist Arbitrary Funcname Return String End Unopexp 
    Simpexp Block Op Util Label Goto Class Error 
);

use AST;

my @state_name_table = ();
$state_name_table[Parser_Stat] = "Stat";
$state_name_table[Parser_Name] = "Name";
$state_name_table[Parser_Prefixexp] = "Prefixexp";
$state_name_table[Parser_Varlist] = "Varlist";
$state_name_table[Parser_Var] = "Var";
$state_name_table[Parser_Args] = "Args";
$state_name_table[Parser_Exp] = "Exp";
$state_name_table[Parser_Explist] = "Explist";
$state_name_table[Parser_Assignment] = "Assignment";
$state_name_table[Parser_Functioncall] = "Functioncall";
$state_name_table[Parser_Tableconstructor] = "Tableconstructor";
$state_name_table[Parser_Local] = "Local";
$state_name_table[Parser_Function] = "Function";
$state_name_table[Parser_Funcname] = "Funcname";
$state_name_table[Parser_Funcbody] = "Function body";
$state_name_table[Parser_Namelist] = "Namelist";
$state_name_table[Parser_Paralist] = "Paralist";
$state_name_table[Parser_If] = "If";
$state_name_table[Parser_While] = "While";
$state_name_table[Parser_For] = "For";
$state_name_table[Parser_Repeat] = "Repeat";
$state_name_table[Parser_Do] = "Do";
$state_name_table[Parser_Op] = "Operator";
$state_name_table[Parser_Break] = "Break";
$state_name_table[Parser_Return] = "Return";
$state_name_table[Parser_End] = "End";
$state_name_table[Parser_Error] = "Error";
$state_name_table[Parser_Simpexp] = "Simpexp";
$state_name_table[Parser_Field] = "Field";
$state_name_table[Parser_Unopexp] = "exp";
$state_name_table[Parser_Util] = "Util";
$state_name_table[Parser_Label] = "Label";
$state_name_table[Parser_Goto] = "Goto";
$state_name_table[Parser_Class] = "Class";

my @state_func_map=();
$state_func_map[Parser_Var] = \&parser_var;
$state_func_map[Parser_Varlist] = \&parser_varlist;
$state_func_map[Parser_Prefixexp] = \&parser_prefixexp;
$state_func_map[Parser_Name] = \&parser_name;
$state_func_map[Parser_Namelist] = \&parser_namelist;
#$state_func_map[Parser_Functioncall] = \&parser_functioncall;
$state_func_map[Parser_Tableconstructor] = \&parser_tableconstructor;
$state_func_map[Parser_Paralist] = \&parser_paralist;
$state_func_map[Parser_Local] = \&parser_local;
$state_func_map[Parser_Function] = \&parser_function;
$state_func_map[Parser_Funcname] = \&parser_funcname;
$state_func_map[Parser_Funcbody] = \&parser_funcbody;
$state_func_map[Parser_Field] = \&parser_field;
$state_func_map[Parser_Explist] = \&parser_explist;
$state_func_map[Parser_Exp] = \&parser_exp;
$state_func_map[Parser_Unopexp] = \&parser_exp;
$state_func_map[Parser_Repeat] = \&parser_repeat;
$state_func_map[Parser_If] = \&parser_if;
$state_func_map[Parser_For] = \&parser_for;
$state_func_map[Parser_While] = \&parser_while;
$state_func_map[Parser_Do] = \&parser_do;
$state_func_map[Parser_Simpexp] = \&parser_simpexp;
$state_func_map[Parser_Assignment] = \&parser_assignment;
$state_func_map[Parser_Args] = \&parser_args;
$state_func_map[Parser_Return] = \&parser_return;
$state_func_map[Parser_Break] = \&parser_break;
$state_func_map[Parser_Op] = \&parser_op;
$state_func_map[Parser_Util] = \&parser_util;
$state_func_map[Parser_Label] = \&parser_label;
$state_func_map[Parser_Goto] = \&parser_goto;
$state_func_map[Parser_Class] = \&parser_class;
$state_func_map[Parser_End] = \&parser_end;

my %parentheses_pair = (
  "(" => ")",
  "{" => "}",
  "[" => "]",
);

my %opt_map = (
  v => 0x01,
  V => 0x02,
  t => 0x04,
  j => 0x08,
  a => 0x10,
);

sub print_parser_state{
  my $state = shift(@_);
  print "parser state : $state_name_table[$state]\n";
}

sub get_varname {
  my $node = shift;
  my $str = "" ;
  if( length( ${$node}{value} ) ) {
    $str = $str . ${$node}{value};
  }
  
  for my $child( @{${$node}{child}} ){
    my $ret = get_varname( $child );
    if( ${$child}{name} eq "Exp" ) {
      $ret = "[" . $ret . "]";
    }
    $str = $str . $ret;
  }
  return $str;
}

sub get_namelist{
  my $node = shift;
  my $end_line = shift;
  my @names= (); 

  for my $child ( @{${$node}{child}} ){
    my $str = ${$child}{value};
    my $start_line = ${$child}{line};
    push( @names, [ $str, "v", [ $start_line, $end_line ] ] );
  }
  return \@names;
}

sub get_varlist{
  my $node = shift;
  my @vars = (); 
  
  for my $child( @{${$node}{child}} ){
    my $str = get_varname( $child );
    push( @vars, $str );
  }
  return \@vars;
}

sub register_variable{
  my $parser = shift;
  my $node = shift;
  my $vars = shift;
  my $assign_tbl = ${$parser}{assign_tbl};
  my $line = ${$node}{line};
  for my $var ( @$vars ){
    next if ( ${$assign_tbl}{$var} ); # already exist
    ${$assign_tbl}{$var} = $line;
  }
}

sub dump_assign_table{
  my $parser = shift;
  my $assign_tbl = ${$parser}{assign_tbl};
  my $i = 0;
  print "{ \"Assignment\": [\n";
  for my $key ( keys %$assign_tbl ){
    print ",\n" if $i > 0 ;
    print "  { \"Name\": \"" . $key . "\"";
    print ", \"Line\": " . ${$assign_tbl}{$key} . " }";
    $i++;
  }
  print "\n]}\n"
}

sub proc_assign_table_member{
  my $parser = shift;
  my $table_var_root = ${$parser}{table_var_root};
  my $assign_tbl = ${$parser}{assign_tbl};
  for my $key ( keys %$assign_tbl ){
    if( $key =~ /\./ ) {
      my @names = split( /\./, $key );
      my $name = $names[$#names];
      my $path = join( '/', @names );
      my $table = AST::create_node( $name, "v"); 
      my $exist = AST::get_child( $table_var_root, $path );
      if( not $exist ) {
        pop( @names );
        $path = join( '/', @names );
        AST::add_child_by_path( $table_var_root, $table, $path);
      }
    }
  }
}

sub proc_assign_func{
  my $parser = shift;
  my $node = shift; #Exp/Function body
  my $fname = shift;
  my $tbl_var_root = ${$parser}{table_var_root};
  my $var_tbl = ${$parser}{var_tbl};

  my $block_end = get_blockend( ${$node}{parent} );
  if( $fname =~ /\./ ) { # table memeber
    my @names = split( /\./, $fname);
    my $name = $names[$#names];
    my $path = join( '/', @names );
    my $func = AST::create_node( $name, "f" );
    my $exist = AST::get_child( $tbl_var_root, $path );
    if( not $exist ) {
      pop( @names );
      $path = join( '/', @names );
      ${$func}{sline} = ${$node}{line};
      ${$func}{eline} = $block_end;
      AST::add_child_by_path( $tbl_var_root, $func, $path);
    }
  }
  my @var = ( $fname, "f", [${$node}{line}, $block_end]);
  push( @{${$var_tbl}{ $var[0] }}, \@var);
}

sub proc_assignment{
  my $parser = shift;
  my $node = shift; # Assignment
  my @vars = ();
  my $i = 0;
  for my $child( @{${$node}{child}} ){
    last if ${$child}{name} eq "Explist";
    if( ${$child}{name} eq "Var" )
    {
      my $is_funcdef = AST::get_child( $node, "Explist#" .$i . "/Exp/Function body");
      $i++;
      my $ret= get_varname( $child );
      if( $is_funcdef ) {
        proc_assign_func( $parser, $is_funcdef, $ret );
        next;
      }
      push( @vars, $ret );
    }else { # 'Varlist'
      my $ret= get_varlist( $child );
      for my $var ( @{$ret} ){
        my $is_funcdef = AST::get_child( $node, "Explist#" .$i . "/Exp/Function body");
        $i++;
        if( $is_funcdef ) {
          proc_assign_func( $parser, $is_funcdef, $var );
          next;
        }
        push( @vars, $var );
      }
    }
  }
  register_variable( $parser, $node, \@vars );
}

sub get_blockend{
  my $node = shift;
  my $child = ${$node}{child};
  my $last = $#{$child};
  my $block_end;
  if( $last >=0 && not defined( ${$child}[$last] ) ) {
    $last = -1; 
  }
  if( $last >= 0 ) {
    $block_end = get_blockend( ${$child }[$last] );
  }else {
    return ${$node}{line};
  }
  return $block_end;
}


sub proc_is_funcdef{
  my $node = shift; #Explist
  my $idx = shift;
  my $child = AST::get_child( $node, "Exp#" . $idx . "/Function body" ); 
  if( $child ) {
    return 1;
  }else {
    return 0;
  }
}

sub proc_is_table{
  my $node = shift; #Explist
  my $idx = shift;
  my $child = AST::get_child( $node, "Exp#" . $idx . "/Tableconstructor" ); 
  if( $child ) {
    return 1;
  }else {
    return 0;
  }
}

sub proc_table{
  my $node = shift; #Exp
  my $table_root = shift;
  my $table_node = AST::get_child( $node, "Tableconstructor" ); # Exp/Tableconstructor
  # field traverse
  my $idx = 0;
  for( my $i = 0;  ; $i++ ){
    my $child = AST::get_child( $table_node, "Field#" . $i );  # Exp/Tableconstructor/Field
    last unless( $child );
    my $name = AST::get_child( $child, "Name" );
    my $field;
    if( $name ) {
      my $is_funcdef = AST::get_child( $child, "Exp/Function body");
      if( $is_funcdef ) {
        $field = AST::create_node( ${$name}{value}, "f" );
        ${$field}{eline} = get_blockend( AST::get_child( $is_funcdef, ".." ) );
        ${$field}{sline} = ${$is_funcdef}{line};
      }else {
        $field = AST::create_node( ${$name}{value}, "v" );
      }
    }else {
      #$field = AST::create_node( "$idx", "");
      $idx++;
    }
    my $nest_table = AST::get_child( $child, "Exp/Tableconstructor" );
    if( $nest_table ) {
      $child = AST::get_child( $child, "Exp" );
      proc_table( $child, $field );
    }
    AST::add_child( $table_root, $field ) if $field;
  }
}

sub proc_self_to_class{ # target : funcbody
  my $node = shift; 
  my $class = shift;
  for my $child ( @{${$node}{child}} ){
    if( $$child{name} eq "Name" && $$child{value} eq "self" ){
      $$child{value} = $class;
    }
    proc_self_to_class( $child, $class );
  }
}

sub proc_function{
  my $parser = shift;
  my $node = shift;
  my $var_tbl = ${$parser}{var_tbl};
  my $table_var_root = ${$parser}{table_var_root};
  my $funcname = AST::get_child( $node, "Funcname" );
  my $class = AST::get_child( $node, "Funcname/Class" );
  my $block_end = get_blockend( $node );
  my $name;
  if( $class ) {
    proc_self_to_class( $node, $$class{value} );
    my $table_path = $$class{value}; 
    my $table = AST::create_node( $$funcname{value}, "f"); 
    AST::add_child_by_path( $table_var_root, $table, $table_path );
    $name = $$class{value} . ":" . $$funcname{value};
  }else {
    $name = $$funcname{value};
  }
  my @var = ($name, "f", [${$funcname}{line}, $block_end]);
  push( @{${$var_tbl}{ $var[0] }}, \@var);
  return;
}

sub proc_local{
  my $parser = shift;
  my $node = shift;
  my $parent = ${$node}{parent};
  my $var_tbl = ${$parser}{var_tbl};
  my $table_var_root = ${$parser}{table_var_root};
  my $child;
  my $block_end = get_blockend( $parent );
  if( $child = AST::get_child( $node, "Name" ) ) { #function definition
    my $block_end = get_blockend( $node );
    my @name = (${$child}{value}, "f", [${$child}{line}, $block_end]);
    push( @{${$var_tbl}{ $name[0] }}, \@name );
    return;
  }
  $child = AST::get_child( $node, "Namelist" );
  my $names = get_namelist( $child, $block_end ); # Namelist
  $child = AST::get_child( $node, "Explist" );
  my $i = 0;
  for my $name ( @$names ) {
    my $is_func = proc_is_funcdef( $child, $i ); #Explist
    if( $is_func ) {
      ${$name}[1] = "f";
      $block_end = get_blockend( $child );
      ${$name}[2][1] = $block_end;
    }
    elsif ( proc_is_table( $child, $i ) ){ 
      ${$name}[1] = "t";
      $block_end = get_blockend( $child );
      ${$name}[2][1] = $block_end;
      my $table = AST::create_node( ${$name}[0], "v"); 
      proc_table( AST::get_child( $child, "Exp#" . $i ), $table );
      AST::add_child( $table_var_root, $table );
    }
    push( @{${$var_tbl}{ ${$name}[0] }}, $name );
    $i++;
  }
}

sub dump_var_table{
  my $parser = shift;
  my $var_tbl = ${$parser}{var_tbl};
  my $j = 0;
  print "{\"Variable\": [\n";
  for my $key ( keys %$var_tbl ){
    my $num = @{${$var_tbl}{$key}};
    print ", " if $j > 0;
    print "{\"Name\": \"" . $key . "\", ";
    print "\"type\": \"" . ${$var_tbl}{$key}[0][1] . "\", ";
    print "\"Scope\": [";
    for (my $i=0; $i < $num; $i++){
      print ", " if $i > 0;
      print "{ \"s\": " . ${$var_tbl}{$key}[$i][2][0] 
      . ", \"e\": " . ${$var_tbl}{$key}[$i][2][1] 
      . "}";
    }
    print "]}\n";
    $j++;
  }
  print "]}\n";
}

sub ast_tree_dump {
  my $parser = shift;
  my $print_func = shift( @_ );
  my $prefix = shift( @_ );
  my $root = ${$parser}{root};
  my $value = ${$root}{value};

  if( ${$parser}{opt} & $opt_map{V} ) {
    print $prefix . ${$root}{name} . ": ";
    if ( $value ) {
      $print_func->( ${$root}{value} );
    }
    print "\t___[" . ${$root}{line};
    print "]\n";
  }
  for my $child( @{${$root}{child}} ){
    if( ${$child}{name} eq "Assignment" ) {
      proc_assignment( $parser, $child );
    }elsif( ${$child}{name} eq "Local" ) {
      proc_local( $parser, $child );
    }elsif( $$child{name} eq "Function" ) {
      proc_function( $parser, $child );
    }
    ${$parser}{root} = $child;
    ast_tree_dump( $parser, $print_func, $prefix . "  "  );
    ${$parser}{root} = $root;
  }
}

sub ast2json {
  my $root = shift(@_);
  my $value = ${$root}{value};
  #print "{ \"Name\": \"" . ${$root}{name} . "\", ";
  return unless ${$root}{name};
  print "{ \"" . ${$root}{name} . "\":{ ";
  if ( $value ) {
    $value =~ s/\\/\\\\/g;
    $value =~ s/"/\\"/g;
    print "\"Value\":\"" . $value . "\", ";
  }
  print "\"Line\": " . ${$root}{line} . ", ";
  print "\"Child\": [\n";
  my $i = 0;
  for my $child( @{${$root}{child}} ){
    last if not defined $child;
    print "," if $i > 0;
    ast2json( $child ); 
    $i++;
  }
  print "]}\n}";
}

# store a statement
BEGIN {
  my %literal = (
    "Name" => 1,
    "String" => 1,
    "Number" => 1,
  );
  sub stat_push {
    my $parser = shift(@_);
    my $tokens = %$parser{tokens};
    my $token = shift(@_);
    push ( @$tokens, $token );
  }
  sub stat_pop {
    my $parser = shift(@_);
    my $tokens = %$parser{tokens};
    return pop ( @$tokens );
  }
  sub stat_shift {
    my $parser = shift(@_);
    my $tokens = %$parser{tokens};
    return shift ( @$tokens );
  }
  sub stat_unshift {
    my $parser = shift(@_);
    my $tokens = %$parser{tokens};
    my $token = shift(@_);
    return unshift( @$tokens, $token );
  }
  sub stat_dump{
    my $parser = shift(@_);
    my $token;
    my $str = stat_dumptostring( $parser );
    print __LINE__ . " dump stat stack:\n" . $str;
    print "\n";
  }
  sub stat_dumptostring{
    my $parser = shift(@_);
    my $token;
    my $str = "";
    while( $token = stat_shift( $parser ) ) {
      if( length( $str ) ){ 
        $str = $str . " ";
      }
      if ( $literal{ %$token{name} } ) {
        $str = $str .  %$token{value};
      }else {
        $str = $str .  %$token{name};
      }
    }
    return $str;
  }
  sub dump_tokens {
    my $tokens = shift(@_);
    while( my $token = shift( @$tokens ) ) {
      dump_token( $token );
    }
    print "\n";
  }
  sub dump_token {
    my $token = shift(@_);
    if ( $literal{ %$token{name} } ) {
      print %$token{value} . " ";
    }else {
      print %$token{name} . " ";
    }
  }
}

sub parser_error{
  my $parser = shift( @_ );
  my $message = shift( @_ );
  stat_dump( $parser );
  die "line : " . %$parser{line} . " " . $message;
}

# exp state machine
BEGIN{
  my @transition = ();
  $transition[Parser_Exp] = {
    "+" => Parser_Exp,
    "*" => Parser_Exp,
    "-" => Parser_Exp,
    "/" => Parser_Exp,
    "//" => Parser_Exp,
    "^" => Parser_Exp,
    "%" => Parser_Exp,
    ".." => Parser_Exp,
    ">" => Parser_Exp,
    "<" => Parser_Exp,
    "<=" => Parser_Exp,
    ">=" => Parser_Exp,
    "==" => Parser_Exp,
    "~=" => Parser_Exp,
    "and" => Parser_Exp,
    "or" => Parser_Exp,
  };
  $transition[Parser_Unopexp] = {
    "#" => Parser_Unopexp,
    "not" => Parser_Unopexp,
    "-" => Parser_Unopexp,
    "{" => Parser_Tableconstructor,
    "(" => Parser_Prefixexp,
    "Name" => Parser_Prefixexp,
    "nil" => Parser_Simpexp,
    "false" => Parser_Simpexp,
    "true" => Parser_Simpexp,
    "Number" => Parser_Simpexp,
    "String" => Parser_Simpexp,
    "..." => Parser_Simpexp,
    "function" => Parser_Funcbody,
  };
  my %unop = (
    "#" => 1,
    "not" => 1,
    "-" => 1,
  );
  my %biop = (
    "+" => 1,
    "*" => 1,
    "-" => 1,
    "/" => 1,
    "//" => 1,
    "^" => 1,
    "%" => 1,
    ".." => 1,
    ">" => 1,
    "<" => 1,
    "<=" => 1,
    ">=" => 1,
    "==" => 1,
    "~=" => 1,
    "and" => 1,
    "or" => 1,
  );
  sub parser_exp{
    my $parser= shift;
    my $state = shift;
    my $token;
    while( $token = parser_getToken($parser) ) {
      my $name = %$token{name};
      if( not defined ($transition[$state]{$name}) ){
        parser_ungetToken( $parser, $token );
        last;
      }
      $state = $transition[$state]{$name};
      if( defined $unop{%$token{name}} ) # unop 
      {
        parser_func_wraper( $parser, Parser_Op );
        next;
      }
      if( $state == Parser_Funcbody ){
        stat_pop( $parser ); # remove keyword 'function'
      }
      parser_func_wraper( $parser, $state );
      if( $state == Parser_Funcbody ){
        parser_func_wraper( $parser, Parser_End );
        last;
      }
      $state = Parser_Unopexp;
      $token = parser_getToken($parser);
      if( defined $biop{%$token{name}} ) # exp biop exp
      {
        parser_func_wraper( $parser, Parser_Op );
        next;
      }
      parser_ungetToken( $parser, $token );
      last;
    }
    AST::rearrange_ast2exp( ${$parser}{root} ) if $state == Parser_Unopexp;
    return Parser_Exp;
  }
}

sub parser_namelist{
  my $parser = shift(@_);
  my $state = Parser_Varlist;
  my $token;
  my $name;
  do {
    parser_func_wraper( $parser, Parser_Name);
    $token = parser_getToken($parser);

    return Parser_Namelist unless $token;

    $name = %$token{name};
    stat_pop( $parser ) if $name eq ","; # remove ','
  }while( $name eq ",");

  parser_ungetToken( $parser, $token );
  return Parser_Namelist;
}

sub parser_varlist{
  my $parser = shift(@_);
  my $state = Parser_Varlist;
  my $token;
  my $name;
  do {
    $state = parser_func_wraper( $parser, Parser_Prefixexp );
    ( $state != Parser_Var && $state != Parser_Name )
      ? parser_error $parser, 
      "syntax error : variable can't be prefixexp or functioncall\n" 
      : return Parser_Varlist;
    $token = parser_getToken($parser);
    return Parser_Varlist unless $token;
    $name = %$token{name};
  }while( $name eq ",");

  parser_ungetToken( $parser, $token );
  return Parser_Varlist;
}

sub parser_explist{
  my $parser = shift(@_);
  my $state = shift(@_);
  my $token;
  my $name;
  do {
    parser_func_wraper($parser, Parser_Unopexp);
    $token = parser_getToken($parser);
    return Parser_Explist unless $token;
    $name = %$token{name};
    stat_pop( $parser );
  }while( $name eq ",");

  parser_ungetToken( $parser, $token );
  return Parser_Explist;
}

# prefixexp state machine
BEGIN{
  my @transition = ();
  $transition[Parser_Name] = {
    "(" => Parser_Args,
    "{" => Parser_Args,
    ":" => Parser_Functioncall,
    "String" => Parser_Args,
    "." => Parser_Name,
    "[" => Parser_Unopexp,
  };
  $transition[Parser_Prefixexp] = {
    "(" => Parser_Unopexp,
    "Name" => Parser_Name,
  };
  $transition[Parser_Var] = {
    "(" => Parser_Args,
    "{" => Parser_Args,
    "." => Parser_Name,
    ":" => Parser_Functioncall,
    "[" => Parser_Unopexp,
  };
  $transition[Parser_Functioncall] = {
    "." => Parser_Var,
    "[" => Parser_Unopexp,
    ":" => Parser_Name,
  };
  $transition[Parser_Exp] = {
    "." => Parser_Var,
    "[" => Parser_Unopexp,
  };
  sub parser_prefixexp{
    my $parser = shift(@_);
    my $state = shift(@_);
    my $token;
    while( $token = parser_getToken($parser) ) {
      my $name = %$token{name};
      if( not defined ($transition[$state]{$name}) ){
        parser_ungetToken( $parser, $token );
        last;
      }
      $state = $transition[$state]{$name};
      if ( $state == Parser_Functioncall) {
        parser_func_wraper( $parser, Parser_Name);
        parser_func_wraper( $parser, Parser_Args);
      }else {
        parser_func_wraper( $parser, $state);
      }
      if ( $name == "[" && $state == Parser_Unopexp) {
        $state = Parser_Var;
      }
      if ( $name == "(" && $state == Parser_Unopexp) {
        $state = Parser_Exp;
      }
      if ( $state == Parser_Args) {
        $state = Parser_Functioncall;
      }
    }
    if ( $state == Parser_Name) {
      $state = Parser_Var;
    }
    return $state;
  }
}

sub parentheses_check {
  my $parser = shift;  
  my $name = shift;
  if ( my $pair = $parentheses_pair{$name} ) {
    my $token = parser_getToken($parser);
    $name = %$token{name};
    if( $name ne $pair ) {
      parser_error $parser, "\nparser error : '". $pair .  "' are missing.\n";
    }
    stat_pop( $parser ); # remove ')', "}', ']'
  }
}

sub parser_local {
  my $parser = shift(@_);
  my $state = shift(@_);
  my $token;

  $token = parser_getToken($parser);
  stat_pop( $parser ); # remove local
  $token = parser_getToken($parser);
  parser_error $parser
              ,  "syntax error : local Namelist or local function\n"
              unless ($token);
  # local Namelist [ = explist ]
  if ( ${$token}{name} eq "Name" ) {
    parser_func_wraper( $parser, Parser_Namelist );
    $token = parser_getToken($parser);
    if ( ${$token}{name} = "=" ){ # [ = explist ]
      stat_pop( $parser );
      parser_func_wraper( $parser, Parser_Explist );
    }else {
      parser_ungetToken( $parser, $token );
    }
  }elsif ( ${$token}{name} eq "function" ){ # local function funcbody
    stat_pop( $parser );
    parser_func_wraper( $parser, Parser_Name );
    parser_func_wraper( $parser, Parser_Funcbody );
    parser_func_wraper( $parser, Parser_End );
  }else {
    parser_error $parser,  "syntax error : local Namelist or local function\n";
  }
  return $state;
}

sub parser_tableconstructor{
  my $parser = shift(@_);
  my $token;

  {

  last unless ($token = parser_getToken($parser));
  last if %$token{name} ne "{";
  do {
    stat_pop( $parser ); # remove '{', ';', ','
    parser_func_wraper( $parser, Parser_Field );
    $token = parser_getToken($parser)
  }while( ( %$token{name} eq ";" ) || ( %$token{name} eq "," ) );
  last unless %$token{name} eq "}";
  stat_pop( $parser ); #remove '}'
  return Parser_Tableconstructor;
  }
  # syntax error
  parser_error $parser,  "syntax error : Invalid tableconstructor\n";
}

sub parser_field {
  my $parser = shift(@_);
  my $token;
  my $state = Parser_Field;
  $token = parser_getToken($parser);
  my $name = %$token{name};
  # '[' exp ']' '=' exp
  if ( $name eq "[" ) {
    parser_func_wraper( $parser, Parser_Unopexp );
    parser_expect( $parser, "=");
    parser_func_wraper( $parser, Parser_Unopexp );
  }elsif ( $name eq "Name" ) {
    $token = parser_getToken($parser);
    $name = %$token{name};
    # Name '=' exp
    if ( $name eq "=" ) {
      parser_func_wraper( $parser, Parser_Name);
      parser_expect( $parser, "=" );
      parser_func_wraper( $parser, Parser_Unopexp );
      return Parser_Field;
    }else { # exp
      parser_func_wraper( $parser, Parser_Unopexp );
    }
  }else { # exp
    parser_func_wraper( $parser, Parser_Unopexp );
  }
  return Parser_Field;
}

my %keywords = (
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

sub create_token{
  my %token =  (
    name => "",
    value => ""
  );
  return wantarray ? %token : die;
}

sub scan_name{
  my %token = create_token();
  $token{name} .= "Name";
  $token{value} .= shift(@_);
  while ( defined (my $ch = shift(@{$_[0]})) ){
    if( $ch =~ /[a-zA-Z0-9_]/){
      $token{value} .= $ch;
    } else {
      unshift(@{$_[0]}, $ch);
      last;
    }
  }

  if( exists $keywords{$token{value}} ){
    $token{name} = $token{value};
    $token{value} = "";
  }

  return wantarray ? %token : die;
}

sub scan_number {
  my %token = create_token();
  $token{name} = "Number";
  $token{value} = shift(@_);
  while ( defined (my $ch = shift(@{$_[0]})) ){
    if( $ch =~ /[0-9\.xa-fA-F]/){
      $token{value} .= $ch;
    } else {
      unshift(@{$_[0]}, $ch);
      last;
    }
  }
  return wantarray ? %token : die;
}

sub scan_string{
  my %token = create_token();
  $token{name} = "String";
  my $quote = $token{value} = shift(@_);
  while ( defined (my $ch = shift(@{$_[0]})) ){
    if( $ch =~ /\\/){
      $token{value} .= $ch;
      $ch = shift(@{$_[0]});
      ( defined ($ch) ) ? ($token{value} .= $ch) : last;
      next;
    } 
    if( $ch ne $quote ){
      $token{value} .= $ch;
    } 
    else {
      $token{value} .= $ch;
      last;
    }
  }
  return wantarray ? %token : die;
}

sub scan_op{
  my %multi_length_op = (
    "..." => 1,
    ".." => 1,
    ">=" => 1,
    "<=" => 1,
    "==" => 1,
    "~=" => 1,
    "//" => 1,
    "::" => 1,
  );
  my %token = create_token();
  $token{name} = shift(@_);
  $token{value} = "";
  while ( defined (my $ch = shift(@{$_[0]})) ){
    if( $multi_length_op{$token{name}.$ch}  ){
      $token{name} .= $ch;
    } 
    else {
      unshift(@{$_[0]}, $ch);
      last;
    } 
  }
  $token{name} = "label" if( $token{name} eq "::" );
  return wantarray ? %token : die;
}

sub parser_tokenizer{
  my $as = shift(@_);
  my %token = ();

  {
    return undef if not defined (my $ch = shift(@$as));
    if( $ch =~ /[a-zA-Z_]/){
      %token = scan_name($ch, $as);
    }
    elsif( $ch =~ /[0-9]/){
      %token = scan_number($ch, $as);
    }
    elsif( $ch =~ /["']/){
      %token = scan_string($ch, $as);
    }
    elsif( $ch !~ /\s/ ){
      %token = scan_op($ch, $as);
    }
    else {
      redo;
    }
  }

  return \%token;
}

BEGIN {

  # args : file handle
  # return : parser object.
sub parser_create{
  my $fh = shift(@_);
  my @as = ();
  my @tokens = ();
  my %variable = ();
  my %assign = ();
  my %parser = (
    fh => $fh,
    as => \@as,
    line => 0,
    tokens => \@tokens,
    root => AST::create_node("block", ""),
    var_tbl => \%variable,
    assign_tbl => \%assign,
    table_var_root => AST::create_node("Table", ""),
  );
  return \%parser;
}

sub parser_readline{
  my $parser = shift(@_);
  my $as = %$parser{as};
  my $fh = %$parser{fh};
  ${$parser}{line} = ${$parser}{line} + 1;
  s/^\s+//;   # remove a leading whitespace
  s/\s+$//;   # remove a tailing whitespace
  s/^#!.*$//;  # remove a shell instruction
  @$as = split(//, $_);
}

sub parser_comment{
  my $parser = shift(@_);
  my $as = %$parser{as};
  my $fh = %$parser{fh};
  my @block_seq = ();
  my @pattern; 
  my $ch;

  my $str;
  while(1){
    if( $#$as < 0 ) {
      return unless $_= <$fh>;
      parser_readline( $parser );
    }
    while( defined( $ch =  shift( @$as ) ) ) { #remove leading space
      if( not ($ch =~ /\s/) ) {
        unshift( @$as, $ch );
        last;
      }
    }
    next if $#$as < 0;

    @pattern = ( '-', '-', '[', '[' );
    @block_seq = ();
    while( defined( $ch =  shift( @$as ) ) ) { # comment pattern matching
      my $seq;
      last if( not defined( $seq = shift(@pattern) ) );
      if( $ch eq $seq ){
        push( @block_seq, $ch );
      }else {
        unshift( @$as, $ch );
        last;
      }
    }

    $str = join('', @block_seq );
    if( $str eq "--" ) {
      @$as = ();
      next;
    }
    last if $str eq "--[[";
    if( $str =~ /^--/ ) { # --[
      @$as = ();
      next;
    }
    while( defined( $ch = pop( @block_seq ) ) ){
      unshift( @$as, $ch );
    }
    return;
  } # while loop
  
  if( $str ne "--[[" ) { # if not block comment
    for $ch ( pop( @block_seq ) ) {
      unshift( @$as, $ch );
    }
    return;
  }

  @block_seq = ();
  while( 1 ){
    next if( not defined( $ch = shift( @$as ) ) );
    my $num_of_seq = @block_seq;
    if( $num_of_seq == 4) { # a <-- b c d <-- e
      shift( @block_seq );
    }
    push( @block_seq, $ch );
    $str = join( '', @block_seq );
    if( $str eq "--]]" ) {
      return;
    }else {
      redo;
    }
  }
  continue {
    return unless $_ = <$fh>;
    parser_readline( $parser );
    @block_seq = ();
  }
}

# args : file handle
# return : hash reference
sub parser_getToken{
  my $parser = shift(@_);
  my $as = %$parser{as};
  my $fh = %$parser{fh};

  parser_comment( $parser );
  if ( defined (my $ch = shift(@$as)) ) {
    unshift( @$as, $ch );
    my $token = parser_tokenizer($as); 
    return parser_getToken( $parser ) unless $token;
    stat_push( $parser, $token );
    return $token;
  }
  return undef unless $fh;
  while (<$fh>) {
    ${$parser}{line} = ${$parser}{line} + 1;
    s/^\s+//;   # remove a leading whitespace
    s/\s+$//;   # remove a tailing whitespace
    s/^#!.*$//;  # remove a shell instruction
    s/^--.*$//;  # remove a comment line
    next if length($_) == 0;
    @$as = split(//, $_);
    next unless ( my $token = parser_tokenizer($as) ); 
    stat_push( $parser, $token );
    return $token;
  } 
  # end of file
  return undef;
}

sub parser_expect{
  my $parser = shift(@_);
  my $str = shift(@_);
  my $token = parser_getToken( $parser );
  stat_pop( $parser ); # delete $str.
  if ( ${$token}{name} ne $str ) {
    parser_error $parser, "syntax error: \'$str\' is expected\n";
  }
}

sub parser_ungetToken{
  my $parser = shift(@_);
  my $token = shift(@_);
  my $as = %$parser{as};
  my $name = %$token{name};
  my $value = %$token{value};
  my @arr=();

  stat_pop( $parser ) if %$token{name};
  # if name == "Name", "Number", "String" then unshift value.
  if ($name eq "Name" || $name eq "Number" || $name eq "String" ) {
    @arr = split(//, $value . " ");
  } else {
    $name = "::" if $name eq "label";
    @arr = split(//, $name . " ");
  }
  unshift(@$as, @arr);
}

sub parser_ungetAllToken{
  my $parser = shift(@_);
  my $as = %$parser{as};
  my $token;

  while( $token = stat_pop( $parser ) )
  {
    my $name = %$token{name};
    my $value = %$token{value};
    my @arr=();
    if ($name eq "Name" || $name eq "Number" || $name eq "String") {
      @arr = split(//, $value . " ");
    } else {
      $name = "::" if $name eq "label";
      @arr = split(//, $name. " ");
    }
    unshift(@$as, @arr);
  }
}

}

sub parser_assignment {
  my $parser = shift(@_);
  parser_func_wraper( $parser, Parser_Prefixexp);
  #parser_func_wraper( $parser, Parser_Varlist );
  my $token = parser_getToken($parser);
  if( %$token{name} ne "=" && %$token{name} ne "," ) {
    parser_ungetToken( $parser, $token );
    ###############################################
    # delete redundant depth functioncall/functioncall
    ###############################################
    my $root = ${$parser}{root};
    my $child = AST::get_child( $root, "Functioncall" );
    my $parent = ${$root}{parent};
    pop( @{${$parent}{child}} );
    AST::add_child( ${${$parser}{root}}{parent}, $child );
    ###############################################
    return Parser_Functioncall;
  }
  if (%$token{name} eq ",") {
    stat_pop( $parser ); # remove ','
    parser_func_wraper( $parser, Parser_Varlist );
    $token = parser_getToken($parser);
  }
  if( %$token{name} ne "=" ) {
    parser_error $parser,  "syntax error : missing '=' \n";
  }
  stat_pop( $parser ); # remove '='
  parser_func_wraper( $parser, Parser_Explist);
  return Parser_Assignment;
}

# if exp then block {elseif exp then block} [else block] end
sub parser_if {
  my $parser = shift(@_);
  my $token = parser_getToken($parser); #if
  do {
    if ( %$token{name} eq "if" ) {
      stat_pop( $parser ); # remove if
      parser_func_wraper($parser, Parser_Unopexp); # exp
      parser_expect( $parser, "then");
      while (parser_stat_decision($parser) != Parser_End){} # block
    }elsif ( %$token{name} eq "elseif" ) { #elseif
      stat_pop( $parser ); # remove elseif
      parser_func_wraper( $parser, Parser_Unopexp ); # exp
      parser_expect( $parser, "then");
      while (parser_stat_decision($parser) != Parser_End){} # block
    }elsif ( %$token{name} eq "else" ) { # else
      stat_pop( $parser ); # remove else
      while (parser_stat_decision($parser) != Parser_End){} # block
    }elsif ( %$token{name} eq "end" ) {
      my $root = ${$parser}{root};
      ${$parser}{root} = ${$root}{parent};
      parser_func_wraper( $parser, Parser_End); # end 
      ${$parser}{root} = $root;
      return Parser_If;
    }else {
      parser_error $parser,  "syntax error : 'end' missing\n";
    }
  }while( $token = parser_getToken($parser) );
  parser_expect( $parser, "end");
  return Parser_If;
}

# for Name `=´ exp `,´ exp [`,´ exp] do block end
# for namelist in explist do block end
sub parser_for {
  my $parser = shift(@_);
  my $token = parser_getToken($parser); # for 
  stat_pop( $parser ); # remove 'for'
  $token = parser_getToken($parser); # Name
  parser_error $parser,  "syntax error : for 'Name' or 'Namelist'\n"
    if %$token{name} ne "Name";
  $token = parser_getToken($parser); # '=' or ','
  if ( %$token{name} eq "=" ) {
    stat_pop( $parser ); # remove '='
    parser_func_wraper( $parser, Parser_Name ); # [Name] = exp
    parser_func_wraper( $parser, Parser_Unopexp ); # Name = [exp]
    parser_expect( $parser, "," );
    parser_func_wraper( $parser, Parser_Unopexp );
    $token = parser_getToken($parser); 
    if ( %$token{name} eq "," ){ # = exp, exp, exp
      stat_pop( $parser );
      parser_func_wraper( $parser, Parser_Unopexp );
    }else {
      parser_ungetToken( $parser, $token );
    }
  }elsif ( %$token{name} eq ',') { # Namelist in explist
    parser_func_wraper( $parser, Parser_Namelist ); # Namelist
    parser_expect( $parser, "in" );
    parser_func_wraper( $parser, Parser_Explist); # Namelist
  }elsif ( %$token{name} eq 'in') { # name in explist
    stat_pop( $parser ); # remove 'in'
    parser_func_wraper( $parser, Parser_Namelist ); # Namelist
    parser_func_wraper( $parser, Parser_Explist); # explist 
  }else {
    # error
    parser_error $parser,  "syntax error : for 'Name' or 'Namelist'\n"
  }
  parser_func_wraper( $parser, Parser_Do); # do block end 
  return Parser_For;
}

# repeat block until exp
sub parser_repeat {
  my $parser = shift(@_);
  my $token = parser_getToken($parser); # repeat 
  stat_pop( $parser ); # remove 'repeat'
  while (parser_stat_decision($parser) != Parser_End){} # block
  parser_func_wraper( $parser, Parser_Util); # util exp
  return Parser_Repeat;
}

sub parser_util {
  my $parser = shift(@_);
  my $token = parser_getToken($parser); # util
  stat_pop( $parser ); # remove 'util'
  parser_error $parser,  "syntax error : 'until' statement mssing\n" 
    if ( %$token{name} ne "until" ); 
  parser_func_wraper( $parser, Parser_Unopexp );
  return Parser_Util;
}

# while exp do block end 
sub parser_while {
  my $parser = shift(@_);
  my $token = parser_getToken($parser); # while
  stat_pop( $parser ); # remove 'while'
  parser_func_wraper( $parser, Parser_Unopexp ); # exp
  parser_func_wraper( $parser, Parser_Do ); # do block end 
  return Parser_While;
}

# do block end
sub parser_do{
  my $parser = shift(@_);
  parser_expect( $parser, "do" ); # do
  while (parser_stat_decision($parser) != Parser_End){} # block

  {
    my $root = ${$parser}{root};
    ${$parser}{root} = ${$root}{parent};
    parser_func_wraper( $parser, Parser_End); # end 
    ${$parser}{root} = $root;
  }
  return Parser_Do;
}

# function funcname funcbody
# funcname ::= Name {`.´ Name} [`:´ Name]
# funcbody ::= `(´ [parlist] `)´ block end
# parlist ::= namelist [`,´ `...´] | `...´

sub parser_function {
  my $parser = shift(@_);
  parser_expect( $parser, "function" );
  parser_func_wraper( $parser, Parser_Funcname );
  parser_func_wraper( $parser, Parser_Funcbody );
  parser_func_wraper( $parser, Parser_End );
  return Parser_Function;
}

sub parser_funcbody {
  my $parser = shift(@_);
  parser_expect( $parser, "(" );
  parser_func_wraper( $parser, Parser_Paralist );
  parser_expect( $parser, ")" );
  while ( parser_stat_decision( $parser ) != Parser_End ){} # block
  return Parser_Funcbody;
}

BEGIN {
  my @transition = ();
  $transition[Parser_Funcname] = {
    "Name" => Parser_Name,
  };
  $transition[Parser_Name] = {
    "." => Parser_Funcname,
  };

  sub parser_funcname {
    my $parser = shift(@_);
    my $token;
    my $state = Parser_Funcname;
    my $name;
    while( $token = parser_getToken($parser) ) {
      $name = %$token{name};
      last unless( $state = $transition[$state]{$name} );
    }
    parser_error $parser,  "syntax error: Invalid function name\n"
      if ( $state == Parser_Funcname );
    $name = %$token{name};
    if( $name eq ":" ) { # ':'Name
      stat_pop( $parser); # remove ':'
      parser_func_wraper( $parser, Parser_Class );
      $token = parser_getToken($parser); 
      parser_error $parser,  "syntax error: Invalid function name\n"
        if ( %$token{name} ne "Name");
    } else {
      parser_ungetToken( $parser, $token );
    }
    return Parser_Funcname;
  }
}

BEGIN {
  my @transition = ();
  $transition[Parser_Paralist] = {
    "Name" => Parser_Name,
    "..." => Parser_Arbitrary,
  };
  $transition[Parser_Name] = {
    "," => Parser_Namelist,
  };
  $transition[Parser_Namelist] = {
    "Name" => Parser_Name,
    "..." => Parser_Arbitrary,
  };
  sub parser_paralist{
    my $parser = shift(@_);
    my $token;
    my $state = Parser_Paralist;
    my $name;
    while( $token = parser_getToken($parser) ) {
      $name = %$token{name};
      my $tmp_state;
      last unless( $tmp_state = $transition[$state]{$name} );
      $state = $tmp_state;
      next if ( $state == Parser_Name || $state == Parser_Namelist );
      if ( $state == Parser_Arbitrary ) {
        last;
      }else {
        parser_error $parser,  "syntax error : Invalid parameters \n";
      }
    }
    parser_ungetToken( $parser, $token ) if( $state != Parser_Arbitrary );
    return Parser_Paralist;
  }
}

BEGIN{
  my %stat_func_map = (
    local => Parser_Local,
    if => Parser_If,
    return => Parser_Return,
    break => Parser_Break,
    function => Parser_Function,
    while => Parser_While,
    do => Parser_Do,
    for => Parser_For,
    repeat => Parser_Repeat,
    label => Parser_Label,
    goto => Parser_Goto,
  );
  sub parser_stat_decision {
    my $parser = shift(@_);
    my $state = Parser_End;
    my $token = parser_getToken( $parser );
    return $state unless $token;
    my $name = %$token{name};
    if( $name eq ";" ) {
      stat_pop( $parser );
      return Parser_Stat;
    }
    parser_ungetToken( $parser );
    # functioncall or assignment.
    if( ($name eq "Name") || ($name eq "(") ) {
      $state = Parser_Assignment;
    }
    else {
       unless( $state = $stat_func_map{$name} ){
         #         parser_error( $parser, "syntax error: Invalid statement " . $name );
        parser_ungetToken( $parser, $token );
        return Parser_End;
      }
    }
    parser_func_wraper( $parser, $state );
    return $state;
  }
}

sub parser_name{
  my $parser = shift;
  my $token = parser_getToken( $parser );
  parser_error $parser, "syntax error : Invalid Name\n" 
    unless ${$token}{name} eq "Name";
    #print __LINE__ . "\n";
  return Parser_Name;
}

sub parser_class{
  my $parser = shift;
  my $token = parser_getToken( $parser );
  parser_error $parser, "syntax error : Invalid Name\n" 
    unless ${$token}{name} eq "Name";
  return Parser_Class;
}

sub parser_simpexp{
  my $parser = shift;
  my $token = parser_getToken( $parser );
  return Parser_Simpexp;
}

sub parser_op{
  my $parser = shift;
  my $token = parser_getToken( $parser );
  return Parser_Op;
}
sub parser_end{
  my $parser = shift;
  parser_expect( $parser, "end");
  return Parser_End;
}

sub parser_break{
  my $parser = shift;
  my $token = parser_getToken( $parser );
  #stat_pop( $parser ); # remove 'break';
  return Parser_Break;
}

sub parser_label{
  my $parser = shift;
  parser_expect( $parser, "label");
  parser_func_wraper( $parser, Parser_Name );
  parser_expect( $parser, "label" );
  return Parser_Label;
}

sub parser_return{
  my $parser = shift;
  my $token = parser_getToken( $parser );
  stat_pop( $parser );
  parser_error $parser, "syntax error : Invalid return\n" 
    unless ${$token}{name} eq "return";
  parser_func_wraper( $parser, Parser_Explist );
  return Parser_Return;
}

sub parser_goto{
  my $parser = shift;
  parser_expect( $parser, "goto");
  parser_func_wraper( $parser, Parser_Name);
  return Parser_Goto;
}

sub parser_func_wraper{
  my $parser = shift;
  my $state = shift;
  my $token = stat_pop( $parser );
  my $name = ${$token}{name};
  my $root = ${$parser}{root};
  my $value = ${$token}{value};
  if( $name =~ /[\.\:]/ && $state == Parser_Name ){
   stat_push( $parser, $token ); 
   parser_func_wraper( $parser, Parser_Op );
  }
  elsif( ($name eq "(" || $name eq "[") && $state == Parser_Unopexp ){}
  elsif( $name ) { 
   stat_push( $parser, $token ); 
  }

  parser_ungetAllToken( $parser );
  my $func = $state_func_map[$state];
  unless( $func ){ # Invalid function call
    #parser_expect( ";" );
    return $state;
  }
  ######################
  #create AST child node
  ######################
  my $child = AST::create_node( $state_name_table[$state], "");
  AST::add_child( $root, $child );
  ${$child}{line} = ${$parser}{line};
  ${$parser}{root} = $child; # swap the root with the child
  ######################

  my $ret_state = $func->( $parser, $state ); 

  ######################
  # AST: swap the root with the original root. 
  ######################
  ${$parser}{root} = $root; # swap the chid with the root
  ######################
  ######################
  # AST: update a value of a child node
  ######################
  ${$child}{value} = stat_dumptostring( $parser );
  ${$child}{name} = $state_name_table[$ret_state];
  ######################
  if( ($name eq "(" || $name eq "[") && $state == Parser_Unopexp )
  {
    #print __LINE__ . " wrapper [$name]\n";
    parentheses_check( $parser, $name );
  }
  return $ret_state;
}

BEGIN{
my %transition = (
  "(" => Parser_Explist,
  "{" => Parser_Tableconstructor,
  "String" => Parser_Simpexp,
);
sub parser_args{
  my $parser = shift;
  my $token = parser_getToken( $parser );
  my $name = ${$token}{name};
  my $state = $transition{$name};

  if ( $state == Parser_Explist ) {
    stat_pop( $parser ); # remove "("
  }
  parser_func_wraper( $parser, $state );
  parentheses_check( $parser, $name ); # check ')'
  return Parser_Args;
}
} # end BEGIN

sub tree_print {
  my $val = shift;
  print $val;
}

sub dump_table_tree{
  my $root = shift(@_);
  my $prefix = shift( @_ );
  print "{\"Name\": \"" . ${$root}{name} . "\", \"type\": \"". ${$root}{value} . "\", ";
  if( defined ${$root}{sline} )
  {
    print "\"line\": \"" . ${$root}{sline} . "-" . ${$root}{eline} . "\", ";
  }
  print "\"member\": [";
  my $i = 0;
  for my $child( @{${$root}{child}} ){
    print ", " if $i;
    dump_table_tree( $child, $prefix . "  "  );
    $i++;
  }
  print "]}";
}


sub proc_argv{
  my $parser = shift;
  my $argv = shift;

  ${$parser}{argv} = 0x00;
  for my $v (@$argv){
    if( $v =~ /^-/){
      my @va = split( //, $v );
      shift(@va);
      for my $opt ( @va ) {
        die "unknown option : " . $opt . "\n" if not $opt_map{$opt};
        ${$parser}{opt} = ${$parser}{opt} | $opt_map{$opt};
      }
    }else{ #file name
      ${$parser}{fname} = $v;
    }
  }
}

use Env;
my $parser = undef;
my @stat = ();

$parser = parser_create( undef );
proc_argv( $parser, \@ARGV );
open( my $fh, "< :encoding(UTF-8)", ${$parser}{fname} )
    || die "$0: can't open ${$parser}{fname} for reading: $!";
${$parser}{fh} = $fh;
my $root = ${$parser}{root};
${$root}{value} = ${$parser}{fname};

while ( parser_stat_decision( $parser ) != Parser_End ){
}
if ( my $token = parser_getToken( $parser ) ){
  close($fh);
  parser_error( $parser, "syntax error: Invalid statement [" . ${$token}{name} . "]" );
}

ast_tree_dump( $parser, \&tree_print, "" );
proc_assign_table_member( $parser );
dump_assign_table( $parser ) if ${$parser}{opt} & $opt_map{a};
dump_var_table( $parser ) if ${$parser}{opt} & $opt_map{v};
dump_table_tree( ${$parser}{table_var_root}, "" ) if ${$parser}{opt} & $opt_map{t};
ast2json( $root ) if ${$parser}{opt} & $opt_map{j};
print "\n";

close($fh);
