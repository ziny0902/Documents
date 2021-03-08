#!/usr/bin/lua5.1

function print_range (a, b)
	return a .. " to " .. b
end

local test = "ABCdefGHIjkl123%d%s%wABC"

local i, j = string.find( test, "%d+", 3 )
print( "found '%d+' from " .. i .. " to " .. j )

print( "found 'ABC' at: " .. print_range( test:find( "ABC" ) ) )
print( "found '%d%d%d' at: " .. print_range( test:find( "%d%d%d" ) ) )
print( "found 'ABC' starting at 5: " .. print_range( string.find( test, "ABC", 5 ) ) )
print( "found '%d' at: " .. print_range( string.find( test, '%d', 1, true ) ) .. " with plain search on" )

--[[
found '%d+' from 13 to 15
found 'ABC' at: 1 to 3
found '%d%d%d' at: 13 to 15
found 'ABC' starting at 5: 22 to 24
found '%d' at: 16 to 17 with plain search on
--]]


