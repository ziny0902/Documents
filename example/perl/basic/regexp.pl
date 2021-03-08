my $greeting = "World";
if ("Hello World" =~ /$greeting/) {
    print "It matches\n";
}
else {
    print "It doesn't match\n";
}


# If you're matching against the special default variable $_, the "$_ =~"
# part can be omitted:
$_ = "Hello World";
if (/World/) {
    print "It matches\n";
}
else {
    print "It doesn't match\n";
}

"Hello World" =~ m!World!;   # matches, delimited by '!'
"Hello World" =~ m{World};   # matches, note the matching '{}'
"/usr/bin/perl" =~ m"/perl"; # matches after '/usr/bin',
                             # '/' becomes an ordinary char
use Env;
my $filename = "$HOME/Documents/programing/lua/exviewer/layout.lua";
my $fh = undef;

open($fh, "< :encoding(UTF-8)", $filename)
    || die "$0: can't open $filename for reading: $!";
while (<$fh>) {
  $_ = s/--.*$//r;  # remove a comment
  $_ = s/^\s+//r;   # remove a leading whitespace
  $_ = s/\s+$//r;   # remove a tailing whitespace
  next if ($_ eq "");
  print "$_\n";
  my @token = split(/([^a-zA-Z0-9_]+)/, $_);
  for (@token) { 
    my $token_type = "";
    next if ($_ eq undef);
    if ($_ =~ /^[0-9]+$/) {
      $token_type = "Number";
    }
    elsif ($_ =~ /^[0-9]/) {
      $token_type = "Not a Name";
    }
    elsif ($_ =~ /[a-zA-Z0-9_]+/){
      $token_type = "Name";
    }
    else {
      $token_type = "op"
    }
    print "($token_type)[$_]\n"; 
  }
}
if ($!) {
    die "unexpected error while reading from $filename: $!";
}

close($fh);


