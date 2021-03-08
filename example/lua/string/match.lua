#!/usr/bin/lua5.1

local test = "abc 123 ABC 123 !!! cat d0g -+[]"

print( string.match( test, "123", 8 ) )
print( string.match( test, "ABC" ) )
print( string.match( test, "%-%+%[%]" ) )

--[[
123
ABC
-+[]
--]]

local test = "abc 123 ABC 123 !!! cat d0g -+[]"

print( string.match( test, "%d" ) )
print( string.match( test, "%d%d%d" ) )

--[[
1
123
--]]

local test = "abc 123 ABC 123 !!! cat d0g -+[] 123"

print( string.match( test, "%d+" ) )
print( string.match( test, "%d*" ) )
print( string.match( test, "%d+.-%d+") )
print( string.match( test, "%d+.*%d+") )

--[[
123

123 ABC 123
123 ABC 123 !!! cat d0g -+[] 123
--]]

local test = "abc 123 ABC 456 !!! cat d0g -+[] 789"

for s in ( string.gmatch( test, "%d+" ) ) do
	print( "found: " .. s )
end

--[[
found: 123
found: 456
found: 0
found: 789
--]]

