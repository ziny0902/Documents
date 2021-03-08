#!/usr/bin/lua5.1

print( string.format( "My name is %s. I'm %d years old!", "John", 22 ) )

--[[
My name is John. I'm 22 years old!
--]]

print( string.format( "%s : %d : %i : %f : %e : %g", "Example", 123, 456, 1.23, 1234567890.0, 123.9000000 ) )
print( string.format( "%u : %x = %X : %o : %E : %G : %%", 123, 255, 255, 255, 123456789, 123.40000 ) )

--[[
Example : 123 : 456 : 1.230000 : 1.234568e+09 : 123.9
123 : ff = FF : 377 : 1.234568E+08 : 123.4 : %
--]]

print( string.format( "% d vs. % d", 123, -123 ) )
print( string.format( "%+d vs. %+d", 123, -123 ) )

print( string.format( "[%-5d vs. %-5d]", 123, -123 ) )
print( string.format( "[%05d vs. %05d]", 123, -123 ) )
print( string.format( "[%-8.2f vs. %-8.2f]", 123.000123, -123.000123 ) )
print( string.format( "[%08.2f vs. %08.2f]", 123.000123, -123.000123 ) )
print( string.format( "[%#.2f vs. %#.2f]", 123.00000, -123.00000 ) )
print( string.format( "[%.0f vs. %.0f]", 123.01, -123.01 ) )

--[[
 123 vs. -123
+123 vs. -123
[123   vs. -123 ]
[00123 vs. -0123]
[123.00   vs. -123.00 ]
[00123.00 vs. -0123.00]
[123.00 vs. -123.00]
[123 vs. -123]
--]]

print( string.format( "[% 8.3s]", "12345" ) )

--[[
[     123]
--]]
