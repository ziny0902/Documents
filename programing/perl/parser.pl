use 5.32.0;

use enum qw(
    :Parser_=0 Stat Name Namelist Prefixexp Varlist Var Args Exp  
    Explist Assignment Function Functioncall Tableconstructor Local 
    Field Transition If Do While Repeat For Break Funcbody
    Paralist Arbitrary Funcname Return String End Unopexp 
    Simpexp Block Op Util Error 
);

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

my @state_func_map=();
$state_func_map[Parser_Var] = \&parser_var;
$state_func_map[Parser_Varlist] = \&parser_varlist;
$state_func_map[Parser_Prefixexp] = \&parser_prefixexp;
$state_func_map[Parser_Name] = \&parser_name;
$state_func_map[Parser_Namelist] = \&parser_namelist;
$state_func_map[Parser_Functioncall] = \&parser_functioncall;
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

my %parentheses_pair = (
  "(" => ")",
  "{" => "}",
  "[" => "]",
);

sub print_parser_state{
  my $state = shift(@_);
  print "parser state : $state_name_table[$state]\n";
}

# AST 
sub ast_create_node {
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

sub ast_add_child {
  my $root = shift( @_ );
  my $child_node = shift( @_ );
  push ( @{ ${$root}{child} }, $child_node );
  ${$child_node}{parent} = $root;
} 

sub ast_add_neighbor {
  my $self = shift( @_ );
  my $child_node = shift( @_ );
  push ( @{ ${${$self}{parent}}{child} }, $child_node );
  ${$child_node}{parent} = ${$self}{parent};
}

sub ast_tree_dump {
  my $root = shift(@_);
  my $print_func = shift( @_ );
  my $prefix = shift( @_ );
  my $value = ${$root}{value};
  print $prefix . ${$root}{name} . ": ";
  if ( $value ) {
    $print_func->( ${$root}{value} );
  }
  print "\n";
  #print $prefix . ${$root}{name} . " " . ${$root}{value} . "\n";
  for my $child( @{${$root}{child}} ){
    ast_tree_dump( $child, $print_func, $prefix . "  "  );
  }
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
#    while( $token = stat_shift( $parser ) ) {
#      dump_token( $token );
#    }
    print __LINE__ . " dump stat stack:\n" . $str;
    print "\n";
  }
  sub stat_dumptostring{
    my $parser = shift(@_);
    my $token;
    my $str = "";
    while( $token = stat_shift( $parser ) ) {
      if ( $literal{ %$token{name} } ) {
        $str = $str . " ". %$token{value};
      }else {
        $str = $str . " ". %$token{name};
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
    # print "parser_exp " . __LINE__ . "\n";
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
      $state = Parser_Unopexp;
      $token = parser_getToken($parser);
      if( defined $biop{%$token{name}} ) # exp biop exp
      {
        parser_func_wraper( $parser, Parser_Op );
        next;
      }
      #print __LINE__ . " " . %$token{name} . " not biop\n";
      parser_ungetToken( $parser, $token );
      last;
    }
    #print "parser_exp end " . __LINE__ . "\n";
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
    parser_func_wraper( $parser, Parser_Var );
    # TODO : error handling
    #
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
  #print "parser_explist " . __LINE__ . "\n";
  do {
    parser_func_wraper($parser, Parser_Unopexp);
    # TODO : error handling
    #
    $token = parser_getToken($parser);
    return Parser_Explist unless $token;
    $name = %$token{name};
    stat_pop( $parser );
  }while( $name eq ",");
  #print "parser_explist " . __LINE__ . " end\n";

  parser_ungetToken( $parser, $token );
  return Parser_Explist;
}

# functioncall state machine
sub parser_functioncall {
  my $parser = shift(@_);
  my $state = shift(@_);
  my $token;

  parser_func_wraper( $parser, Parser_Prefixexp);
  $token = parser_getToken($parser); 
  if ( ${$token}{name} eq ":") {
    stat_pop( $parser ); # remove ':'
    parser_func_wraper( $parser, Parser_Name); # prefixexp ':' Name
    parser_func_wraper( $parser, Parser_Args);
  } else {
    parser_ungetToken( $parser, $token );
  }
  return Parser_Functioncall;
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
  };
  $transition[Parser_Exp] = {
    "." => Parser_Var,
    "[" => Parser_Unopexp,
  };
  #TODO
  sub parser_prefixexp{
    #print "parser_prefixexp " . __LINE__ . "\n";
    my $parser = shift(@_);
    my $state = shift(@_);
    my $token;
    while( $token = parser_getToken($parser) ) {
      my $name = %$token{name};
      if( not defined ($transition[$state]{$name}) ){
        # print __LINE__ . " $state $name\n";
        parser_ungetToken( $parser, $token );
        last;
      }
      $state = $transition[$state]{$name};
      #print __LINE__ . " $name\n";
      #print __LINE__ . " ";
      #print_parser_state( $state );
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
    #print __LINE__ . "prefixexp end.\n";
    return $state;
  }
}

sub parentheses_check {
  my $parser = shift;  
  my $name = shift;
  if ( my $pair = $parentheses_pair{$name} ) {
    my $token = parser_getToken($parser);
    $name = %$token{name};
    #print __LINE__ . " $name\n";
    if( $name ne $pair ) {
      parser_error $parser, "\nparser error : '". $pair .  "' are missing.\n";
    }
    stat_pop( $parser ); # remove ')', "}', ']'
  }
}

# var state machine
BEGIN {
  my @transition = ();
  $transition[Parser_Varlist] = {
    "(" => Parser_Prefixexp,
    "Name" => Parser_Name,
  };
  $transition[Parser_Name] = {
    "(" => Parser_Functioncall,
    ":" => Parser_Functioncall,
    "String" => Parser_Functioncall,
    "." => Parser_Name,
    "[" => Parser_Exp,
  };
  $transition[Parser_Prefixexp] = {
    "(" => Parser_Functioncall,
    ":" => Parser_Functioncall,
    "." => Parser_Name,
    "[" => Parser_Exp,
  };
  $transition[Parser_Var] = {
    "(" => Parser_Functioncall,
    ":" => Parser_Functioncall,
    "." => Parser_Name,
    "[" => Parser_Exp,
  };
  $transition[Parser_Functioncall] = {
    "." => Parser_Name,
    "[" => Parser_Exp,
  };

# TODO : prefixexp.Name or prefixexp:Name recursive form
  # args : file handle, parser_state
  # return : status, token reference
  sub parser_var{
    my $parser = shift(@_);
    my $state;
    $state = parser_func_wraper( $parser, Parser_Prefixexp );
    ( $state != Parser_Var && $state != Parser_Name )
      ? parser_error $parser, 
      "syntax error : variable can't be prefixexp or functioncall\n" 
      : return Parser_Var;
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
    # parser_field( $parser );
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
    $token = parser_getToken($parser);
    stat_pop( $parser ); # remove '='
    $name = %$token{name};
    parser_error $parser, "syntax error : '=' missing\n" 
      unless $name eq "=";
    parser_func_wraper( $parser, Parser_Unopexp );
  }elsif ( $name eq "Name" ) {
    $token = parser_getToken($parser);
    $name = %$token{name};
    # Name '=' exp
    if ( $name eq "=" ) {
      #print __LINE__ . "\n";
      while ( stat_pop( $parser ) ) {} # remove Name '='
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

# stat decision machine
BEGIN {
  my @stat_transition = ();
  $stat_transition[Parser_Stat] = {
    "Name" => Parser_Name,
    "(" => Parser_Prefixexp,
    "local" => Parser_Local,
    "if" => Parser_If,
    "else" => Parser_End,
    "elseif" => Parser_End,
    "while" => Parser_While,
    "for" => Parser_For,
    "do" => Parser_Do,
    "repeat" => Parser_Repeat,
    "break" => Parser_Break,
    "return" => Parser_Return,
    "end" => Parser_End,
    "until" => Parser_End,
    "function" => Parser_Function,
  };
  $stat_transition[Parser_Name] = {
    "(" => Parser_Functioncall,
    ":" => Parser_Functioncall,
    "{" => Parser_Functioncall,
    "String" => Parser_Functioncall,
    "," => Parser_Assignment,
    "=" => Parser_Assignment,
    "." => Parser_Var,
    "[" => Parser_Var
  };
  $stat_transition[Parser_Prefixexp] = {
    "(" => Parser_Functioncall,
    ":" => Parser_Functioncall,
    "." => Parser_Var,
    "[" => Parser_Var
  };
  $stat_transition[Parser_Var] = {
    "(" => Parser_Functioncall,
    ":" => Parser_Functioncall,
    "," => Parser_Assignment,
    "=" => Parser_Assignment,
  };
  $stat_transition[Parser_Functioncall] = {
    "." => Parser_Var,
    "[" => Parser_Var,
  };
# args: parser_state, name
# return: Parser_... 
  sub parser_update_state{
    my $parser_state = shift(@_);
    # print "\@_: @_ // parser_state = $parser_state \n";
    my $hash = $stat_transition[$parser_state];
    if (defined %$hash{@_}){
      $parser_state = %$hash{@_}
    } else {
      $parser_state = Parser_Error;
    }

     return $parser_state;
  }
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
  "while" => 1
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
    ".." => 1,
    ">=" => 1,
    "<=" => 1,
    "==" => 1,
    "~=" => 1,
    "//" => 1,
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
  return wantarray ? %token : die;
}

sub parser_tokenizer{
  my $as = shift(@_);
  my %token = ();

  {
    return undef if not defined (my $ch = shift(@$as));
    if( $ch =~ /[a-zA-Z_]/){
      %token = scan_name($ch, $as);
      # print "$token{value}\n" if $token{name} eq "Name";
    }
    elsif( $ch =~ /[0-9]/){
      %token = scan_number($ch, $as);
      # print $token{value};
      # print "\n";
    }
    elsif( $ch =~ /["']/){
      %token = scan_string($ch, $as);
      # print $token{value};
      # print "\n";
    }
    elsif( $ch !~ /\s/ ){
      %token = scan_op($ch, $as);
      # print "$token{name}\n";
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
  my $root = ast_create_node("block", ""); 
  my %parser = (
    fh => $fh,
    as => \@as,
    line => 0,
    tokens => \@tokens,
    root => $root,
  );
  return \%parser;
}

# args : file handle
# return : hash reference
sub parser_getToken{
  my $parser = shift(@_);
  my $as = %$parser{as};
  my $fh = %$parser{fh};
  if ( defined (my $ch = shift(@$as)) ) {
    unshift( @$as, $ch );
    my $token = parser_tokenizer($as); 
    stat_push( $parser, $token );
    return $token;
  }
  return undef unless $fh;
  while (<$fh>) {
    ${$parser}{line} = ${$parser}{line} + 1;
    s/--.*$//;  # remove a comment
    s/^#!.*$//;  # remove a shell instruction
    s/^\s+//;   # remove a leading whitespace
    s/\s+$//;   # remove a tailing whitespace
    next if length($_) == 0;
    @$as = split(//, $_);
    my $token = parser_tokenizer($as); 
    stat_push( $parser, $token );
    return $token;
  } 
  # end of file
  return undef;
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
  if ($name eq "Name" || $name eq "Number" || $name eq "String") {
    @arr = split(//, $value);
  } else {
    @arr = split(//, $name);
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
      @arr = split(//, $value);
    } else {
      @arr = split(//, $name);
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
      $token = parser_getToken($parser); # then
      stat_pop( $parser ); # remove then
      parser_error $parser,  "syntax error : 'then' statement mssing\n" if ( %$token{name} ne "then" ); 
      while (parser_stat_decision($parser) != Parser_End){} # block
    }elsif ( %$token{name} eq "elseif" ) { #elseif
      stat_pop( $parser ); # remove elseif
      parser_func_wraper( $parser, Parser_Unopexp ); # exp
      $token = parser_getToken($parser); #then
      stat_pop( $parser ); # remove then
      parser_error $parser,  "syntax error : 'then' statement mssing\n" if ( %$token{name} ne "then" ); 
      while (parser_stat_decision($parser) != Parser_End){} # block
    }elsif ( %$token{name} eq "else" ) { # else
      stat_pop( $parser ); # remove else
      while (parser_stat_decision($parser) != Parser_End){} # block
    }elsif ( %$token{name} eq "end" ) {
      stat_pop( $parser ); # remove end
      return Parser_If;
    }else {
      parser_error $parser,  "syntax error : 'end' missing\n";
    }
  }while( $token = parser_getToken($parser) );
  stat_pop( $parser ); # remove end
  if ( %$token{name} ne "end" ) {
      parser_error $parser,  "syntax error : 'end' missing\n";
  }
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
    $token = parser_getToken($parser); 
    stat_pop( $parser ); # remove ','
    parser_error $parser,  "syntax error : for ',' missing\n"
      if %$token{name} ne ",";
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
    $token = parser_getToken($parser); 
    stat_pop( $parser ); # remove 'in'
    parser_error $parser,  "syntax error : 'in' missing\n"
      if %$token{name} ne "in";      # Namelist in ...
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
  my $token = parser_getToken($parser); # do
  stat_pop( $parser ); # remove 'do'
  parser_error $parser,  "syntax error : 'do' statement mssing\n" if ( %$token{name} ne "do" ); 
  while (parser_stat_decision($parser) != Parser_End){} # block
  $token = parser_getToken($parser); # end 
  stat_pop( $parser ); # remove 'end'
  parser_error $parser,  "syntax error : 'end' statement mssing\n" if ( %$token{name} ne "end" ); 
  return Parser_Do;
}

# function funcname funcbody
# funcname ::= Name {`.´ Name} [`:´ Name]
# funcbody ::= `(´ [parlist] `)´ block end
# parlist ::= namelist [`,´ `...´] | `...´

sub parser_function {
  my $parser = shift(@_);
  my $token = parser_getToken($parser); # remove 'function' 
  stat_pop( $parser );
  parser_func_wraper( $parser, Parser_Funcname );
  parser_func_wraper( $parser, Parser_Funcbody );
  return Parser_Function;
}

sub parser_funcbody {
  my $parser = shift(@_);
  my $token = parser_getToken($parser); # end 
  if( %$token{name} ne "(" ) {
    parser_error $parser,  "syntax error : parameter missing\n";
  }
  stat_pop( $parser ); # remove '('
  #parser_paralist( $parser );
  parser_func_wraper( $parser, Parser_Paralist );
  $token = parser_getToken($parser); # end 
  if( %$token{name} ne ")" ) {
    parser_error $parser,  "syntax error : ')' missing\n";
  }
  stat_pop( $parser ); # remove ')'
  while ( parser_stat_decision( $parser ) != Parser_End ){} # block
  $token = parser_getToken($parser); # end 
  stat_pop( $parser ); # remove 'end'
  #stat_dump( $parser );
  parser_error $parser,  "syntax error : 'end' statement mssing\n" 
    if ( %$token{name} ne "end" ); 
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
      $token = parser_getToken($parser); 
      parser_error $parser,  "syntax error: Invalid function name\n"
        if ( %$token{name} ne "Name");
    } else {
      parser_ungetToken( $parser, $token );
    }
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
  );
  sub parser_stat_decision {
    my $parser = shift(@_);
    my $state = Parser_End;
    my $token = parser_getToken( $parser );
    return $state unless $token;
    my $name = %$token{name};
    parser_ungetToken( $parser );
    # functioncall or assignment.
    if( ($name eq "Name") || ($name eq "(") ) {
      $state = Parser_Assignment;
    }
    else {
       unless( $state = $stat_func_map{$name} ){
        $state = Parser_End;
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

sub parser_break{
  my $parser = shift;
  my $token = parser_getToken( $parser );
  stat_pop( $parser ); # remove 'break';
  return Parser_Break;
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

sub parser_func_wraper{
  my $parser = shift;
  my $state = shift;
  my $token = stat_pop( $parser );
  my $name = ${$token}{name};
  my $root = ${$parser}{root};
  my $value = ${$token}{value};
  #print __LINE__ . " " . $state . " ";
  #print_parser_state( $state );
  #print __LINE__ . " wrapper [$name] [$value]\n";
  if( $name =~ /[\.\:]/ && $state == Parser_Name ){}
  elsif( ($name eq "(" || $name eq "[") && $state == Parser_Unopexp ){}
  elsif( $name ) { 
   stat_push( $parser, $token ); 
  }

  parser_ungetAllToken( $parser );
  my $func = $state_func_map[$state];
  return $state unless $func; # Invalid function call
  ######################
  #create AST child node
  ######################
  my $child = ast_create_node( $state_name_table[$state], "");
  ast_add_child( $root, $child );
  ${$parser}{root} = $child; # swap the root with the child
  ######################

  my $ret_state = $func->( $parser, $state ); 

  ######################
  # AST: swap the root with the original root. 
  ######################
  ${$parser}{root} = $root; # swap the chid with the root
  ######################
  #print __LINE__ . " " . $ret_state . " ";
  #print_parser_state( $ret_state );
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

use Env;
my $filename = "$HOME/Documents/programing/lua/exviewer/layout.lua";
#my $filename = "test.lua";
my $parser = undef;
my @stat = ();

open(my $fh, "< :encoding(UTF-8)", $filename)
    || die "$0: can't open $filename for reading: $!";

$parser = parser_create( $fh );
my $root = ${$parser}{root};
while ( parser_stat_decision( $parser ) != Parser_End ){
}
  ast_tree_dump( $root, \&tree_print, "" );

close($fh);

