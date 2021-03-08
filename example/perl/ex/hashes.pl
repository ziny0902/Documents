#!/usr/bin/perl

%data = ('John Paul', 45, 'Lisa', 30, 'Kumar', 40);

print "\$data{'John Paul'} = $data{'John Paul'}\n";
print "\$data{'Lisa'} = $data{'Lisa'}\n";
print "\$data{'Kumar'} = $data{'Kumar'}\n";

%data = ('John Paul' => 45, 'Lisa' => 30, 'Kumar' => 40);
%data = (-JohnPaul => 45, -Lisa => 30, -Kumar => 40);
$val = %data{-JohnPaul};
print "$val\n";
print "$data{-JohnPaul}\n";
@array = @data{-JohnPaul, -Lisa};
print "Array : @array\n";
@names = keys %data;

print "$names[0]\n";
print "$names[1]\n";
print "$names[2]\n";

@ages = values %data;

print "$ages[0]\n";
print "$ages[1]\n";
print "$ages[2]\n";

print "\n";

if( exists($data{-Lisa}) ) {
	print "Lisa is $data{-Lisa} years old\n";
} else {
	print "I don't know age of Lisa\n";
}

print "\n";

@keys = keys %data;
$size = @keys;
print "1 - Hash size is $size\n";

# adding an element to the hash;
$data{'Ali'} = 55;
@keys = keys %data;
$size = @keys;
print "2 - Hash size is $size\n";

# delete the same element from the hash

delete $data{'Ali'};
@keys = keys %data;
$size = @keys;
print "3 - Hash size is $size\n";
