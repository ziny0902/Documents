print "type your name : "
name = io.read()

if name == "hwang" then
  print "Authentication success"
  local_var = 100 -- if-else clause local variable
elseif name == "sung" then
  print "Authentication progress"
else
  print "Authentication fail"
end

-- while loop
local cnt = 0
while (cnt < 200) do
  print (cnt)
  cnt = cnt + 1
end

-- for loop
for cnt = 0, 100 do
  print(cnt)
end

for cnt = 0, 100, 2 do
  print(cnt)
end

for cnt = 100, 0, -1 do
  print(cnt)
end

-- repeat - until clause
repeat 
  print "hello"
until(true)
