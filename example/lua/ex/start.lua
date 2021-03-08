-- single line comment
--[[
multi line comment
...

--]] 


a = 20 -- scalar variable.
b = 10

-- string variable
text = "hello world"

multiline = [[
line 1
line 2
line 3
]]

-- conbine string
part1 = "hello"
part2 = "world"
conbine = part1 ..' '.. part2

result = a - b

-- boolean variable
boolean_var = true

print(result) -- console output
print(text)
print(multiline)
print(conbine)
print(boolean_var)
print((10 == 200))
print((10 ~= 200))
print((10 >= 200))
print((10 <= 200))
print((10 < 200))
print((10 > 200))
