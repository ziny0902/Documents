#!/usr/bin/lua5.1

local test = "abc 123 ABC 456 !!! cat d0g -+[] 789"

local newstring, replacements = string.gsub( test, "%d+", "[Numbers]" )
print( "Replaced: " .. replacements )
print( "New string: " .. newstring )

--[[
Replaced: 4
New string: abc [Numbers] ABC [Numbers] !!! cat d[Numbers]g -+[] [Numbers]
--]]

