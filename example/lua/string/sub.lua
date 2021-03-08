
local test = "123456789"

print( "test substring starting at 5: " .. test:sub( 5 ) )
print( "test substring from 5 to 8: " .. string.sub( test, 5, 8 ) )
print( "test substring from -3 to -1: " .. string.sub( test, -3, -1 ) )

--[[
result:
test substring starting at 5: 56789
test substring from 5 to 8: 5678
test substring from -3 to -1: 789
--]]
