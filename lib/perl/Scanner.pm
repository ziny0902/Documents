package Scanner;

sub new{
  my ($class, $args) = @_;
  my $self = bless {
            fh => $args->{fh},
            keywords => $args->{keywords},
            lcomment => $args->{lcomment},
            bcomment_s => $args->{bcomment_s},
            bcomment_e => $args->{bcomment_e},
            mlength_op => $args->{mlength_op},
            qq_unqqs => $args->{qq_unqqs},
            as => (),
            line => 0
            }, $class;
}

sub scan_name{
  my $self = shift;
  my $as = \@{$self->{as}};
  my $keywords = $self->{keywords};
  my %token;  
  $token{name} .= "Name";
  $token{value} .= shift( @$as );
  while ( defined (my $ch = shift( @$as )) ){
    if( $ch =~ /[a-zA-Z0-9_]/){
      $token{value} .= $ch;
    } else {
      unshift(@$as, $ch);
      last;
    }
  }

  if( exists $$keywords{$token{value}} ){
    $token{name} = $token{value};
    $token{value} = "";
  }

  return wantarray ? %token : die;
}

sub scan_number {
  my $self = shift;
  my $as = \@{$self->{as}};
  my %token;
  $token{name} = "Number";
  $token{value} = shift( @$as );
  while ( defined (my $ch = shift( @$as ) ) ){
    if( $ch =~ /[0-9\.xa-fA-F]/){
      $token{value} .= $ch;
    } else {
      unshift(@$as, $ch);
      last;
    }
  }
  return wantarray ? %token : die;
}

sub scan_op{
  my $self = shift;
  my $as = \@{$self->{as}};
  my $mlen_op = $self->{mlength_op};
  my %token;
  $token{name} = shift( @$as );
  $token{value} = "";
  while ( defined ( my $ch = shift( @$as ) ) ){
    if( $$mlen_op{$token{name}.$ch}  ){
      $token{name} .= $ch;
    } 
    else {
      unshift( @$as, $ch );
      last;
    } 
  }
  return wantarray ? %token : die;
}

sub check_quote_seq{
  my $self = shift;
  my $quote_unquote_seq = $self->{qq_unqqs};
  my $as = \@{$self->{as}};
  for( my $i = 0; $i <= $#{$quote_unquote_seq}; $i ++ ) {
    $qq_seq = ${$quote_unquote_seq}[$i];
    my $qq_seq_len = length ${$qq_seq}{quote};
    @slice = @{$as}[0..($qq_seq_len -1)];
    $str = join( '', @slice );
    if( $str eq ${$qq_seq}{quote} ){
      return $self->scan_quote_string( $i );
    }
  }
  return undef;
}

sub scan_quote_string{
  my $self = shift;
  my $idx = shift;
  my $quote_unquote_seq = $self->{qq_unqqs};
  my $qq_seq = ${$quote_unquote_seq}[$idx];
  my $as = \@{$self->{as}};
  my $fh = $self->{fh};
  my @unquote = split( //, ${$qq_seq}{unquote} ); 
  my $ch;
  my $str;

  for( $i = 0; $i < length ${$qq_seq}{quote}; $i++ ){
    $str .= shift( @{$as} );
  }

  my @pattern=();
  while(1){
    if( $#$as < 0 ) {
      die "syntax error:  a quoted string is not enclosed" unless $_= <$fh>;
      $self->readline( $_ );
      $pattern=();
    }
    $ch = shift( @{$as} );
    if( $ch eq '\\' ) {
      next if( $#$as < 0 );
      $str .= $ch;
      $str .= shift( @{$as} );
      next;
    }else {
      shift( @pattern ) if( $#pattern == $#unquote );
      push( @pattern, $ch );
    }
    if( join( '', @pattern) eq ${$qq_seq}{unquote} ) {
      $str .= $ch;
      my %token;
      $token{name} = "String";
      $token{value} = $str;
      return \%token;
    }
    $str .= $ch;
  }
}

sub parser_tokenizer{
  my $self = shift;
  my $as = \@{$self->{as}};
  my %token = ();

  {
    return undef if not defined (my $ch = shift(@$as));
    if( $ch =~ /[a-zA-Z_]/){
      unshift( @$as, $ch );
      %token = $self->scan_name( );
    }
    elsif( $ch =~ /[0-9]/){
      unshift( @$as, $ch );
      %token = $self->scan_number( ); 
    }
    elsif( $ch !~ /\s/ ){
      unshift( @$as, $ch );
      %token = $self->scan_op( );
    }
    else {
      redo;
    }
  }

  return \%token;
}

sub readline{
  my $self = shift;
  my $str = shift;
  $self->{line} = ${self}->{line} + 1;
  @{$self->{as}} = split(//, $str);
}

sub get_line_number{
  my $self = shift;
  return $self->{line};
}

sub parser_comment{
  my $self = shift(@_);
  my $as = \@{$self->{as}};
  my $fh = $self->{fh};
  my $lcomment = $self->{lcomment};
  my $bcomment_s = $self->{bcomment_s};
  my $bcomment_e = $self->{bcomment_e};
  my @block_seq = ();
  my @pattern; 
  my $ch;

  my $str;
  while(1){
    if( $#$as < 0 ) {
      return unless $_= <$fh>;
      $self->readline( $_ );
    }
    while( defined( $ch =  shift( @$as ) ) ) { #remove leading space
      if( not ($ch =~ /\s/) ) {
        unshift( @$as, $ch );
        last;
      }
    }
    next if $#$as < 0;

    @pattern = split( //, $bcomment_s );
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
    if( $str eq $lcomment ) {
      @$as = ();
      next;
    }
    last if $str eq $bcomment_s;
    if( eval( "$str =~ /^$lcomment/" ) ) { # --[
      @$as = ();
      next;
    }
    while( defined( $ch = pop( @block_seq ) ) ){
      unshift( @$as, $ch );
    }
    return;
  } # while loop
  
  if( $str ne $bcomment_s ) { # if not block comment
    for $ch ( pop( @block_seq ) ) {
      unshift( @$as, $ch );
    }
    return;
  }

  @block_seq = ();
  while( 1 ){
    next if( not defined( $ch = shift( @$as ) ) );
    my $num_of_seq = @block_seq;
    if( $num_of_seq == ( length $bcomment_e ) ) { # a <-- b c d <-- e
      shift( @block_seq );
    }
    push( @block_seq, $ch );
    $str = join( '', @block_seq );
    if( $str eq $bcomment_e ) {
      return;
    }else {
      redo;
    }
  }
  continue {
    return unless $_ = <$fh>;
    $self->readline( $_ );
    @block_seq = ();
  }
}


# args : file handle
# return : hash reference
sub getToken{
  my $self = shift(@_);
  my $as = \@{$self->{as}};
  my $fh = $self->{fh};
  my $lcomment = $self->{lcomment};

  $self->parser_comment( ); # comment
  my $token = $self->check_quote_seq( ); # quoted string
  return $token if $token;
  if ( defined (my $ch = shift(@$as)) ) {
    unshift( @$as, $ch );
    my $token = $self->parser_tokenizer( ); 
    return $self->getToken( ) unless $token;
    return $token;
  }
  while (<$fh>) {
    ${$self}{line} = ${$self}{line} + 1;
    s/^\s+//;   # remove a leading whitespace
    s/\s+$//;   # remove a tailing whitespace
    s/^#!.*$//;  # remove a shell instruction
    eval("s/^$lcomment.*$//");  # remove a comment line
    next if length($_) == 0;
    @{$self->{as}} = split(//, $_);
    next unless ( my $token = $self->parser_tokenizer() ); 
    return $token;
  } 
  # end of file
  return undef;
}

sub ungetToken{
  my $self = shift;
  my $arr = shift;
  my $as = \@{$self->{as}};

  unshift(@$as, @$arr);
}

1
