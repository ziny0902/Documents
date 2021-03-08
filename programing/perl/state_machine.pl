use 5.32.0;

use enum qw(
    :Parser_=0 Name Namelist Var Varlist  Exp Explist Prefixexp 
    Parlist Args Functioncall Tableconstructor Field Fieldlist
);

# args: \@tokens
# return: @parser_node
sub stat_parser{
  my $tokens = shift(@_);
  my %token = @$tokens[0];
  if ( $token{name} eq "Name" ) {
    my %next = @$tokens[1];
    if( $next{name} eq "(" ){
      functioncall_parser($tokens);
    }
    else {
      assign_parser($tokens);
    }
  }
  elsif( $token{name} eq "(") {
      assign_parser($tokens);
  }
}

# args: \@tokens
# return: @parser_node
sub assign_parser{
  my $tokens = shift(@_);
  varlist_parser($tokens);
  exp_parser($tokens);
}
# args: \@tokens
# return: @parser_node
sub var_parser {
  if( $token{name} eq "(" ) {                  # `(´ exp `)´
    unshift( @$tokens, $token );
    prefixexp_parser($tokens);

      # TODO: add var to syntax tree

  } elsif( $token{name} eq "[" ){             # prefixexp `[´ exp `]´ 
    exp_parser($tokens);

      # TODO: add var to syntax tree

  } elsif( $token{name} eq "Name" ){
    if( @$tokens[0]{name} eq "(" ) {
      unshift( @$tokens, $token );
      functioncall_parser( $tokens );

      # TODO: add var to syntax tree

    } elsif( @$tokens[0]{name} eq "," ) {

      # TODO: add var to syntax tree

      shift( $tokens ); # consume a ','
      next;
    } else { # error or end of a varlist

      # TODO: add var to syntax tree

      unshift( @$tokens, $token );
      last;
    }
  } elsif( $token{name} eq "." ) {

      # TODO: add var to syntax tree

  } else { # end of a varlist
    unshift( $tokens, $tokens );
    last;
  }
}

# args: \@tokens
# return: @parser_node
sub varlist_parser{
  my $tokens = shift(@_);
  while( defined (my $token = shift(@$tokens)) ){
  }
}

# args: \@tokens
# return: @parser_node
sub functioncall_parser {
}

# args: \@tokens
# return: @parser_node
sub args_parser {
}

# args: \@tokens
# return: @parser_node
sub prefixexp_parser {
}

# args: \@tokens
# return: @parser_node
sub exp_parser {
}
