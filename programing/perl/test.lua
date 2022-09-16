a = 7 ^ 3 + (a + b) * e - -c ^ 2 ^ 3 == d / 8 ^ 3
term.keys = { -- key code definitions
	unknown = 0x10000, -- 0ff
	esc = 0x1b,
	del = 0x7f,
	kf1 = 0xffff,
	kf2 = 0xfffe,
	kf3 = 0xfffd, -- ...
	kf4 = 0xfffc,
	kf5 = 0xfffb, --[[
kf6 = 0xfffa, --]]
	kf7 = 0xfff9,
	kf8 = 0xfff8,
	kf9 = 0xfff7,
	kf10 = 0xfff6,
	kf11 = 0xfff5,
	kf12 = 0xfff4,
	kins = 0xfff3,
	kdel = 0xfff2,
	khome = 0xfff1,
	kend = 0xfff0,
	kpgup = 0xffef,
	kpgdn = 0xffee,
	kup = 0xffed,
	kdown = 0xffec,
	kleft = 0xffeb,
	kright = 0xffea,
}
local table1 = { -- comment test
	a = 0xffff,
	b = 0xfffe, -- adfjaldks
	3, -- adfalkfjal
	c = { a = 1, b = 2 }, -- adlfjalkf
	4,
}
str:match(("([^" .. sep .. "]*)" .. sep):rep(nsep))
local cmd_result = tostring((ls("-l " .. path):awk(action)))
--
-- assignment test suit
--
fact = function(n)
	if n == 0 then
		return 1
	else
		return n * fact(n - 1)
	end
end
d, f = 5, 10
result = math.sqrt(sum / (count - 1))
--
-- table test suit
--
tab = { sin(1), sin(2), sin(3), sin(4), sin(5), sin(6), sin(7), sin(8) }
intervals = {
	{ "seconds", 1 }, --the "1" should never really get used but
	{ "minutes", 60 },
	{ "hours", 60 },
	{ "days", 24 },
}
polyline = {
	color = "blue",
	thickness = 2,
	npoints = 4,
	{ x = 0, y = 0 },
	{ x = -10, y = 0 },
	{ x = -10, y = 1 },
	{ x = 0, y = 1 },
}
opnames = { ["+"] = "add", ["-"] = "sub", ["*"] = "mul", ["/"] = "div" }
a = { [i + 0] = s, [i + 1] = s .. s, [i + 2] = s .. s .. s }
days = { [0] = "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
--
-- function call test suit
--
split("a,b,c", ",")
tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
string.gmatch(example, "%S+")
awful.spawn.with_shell("picom --backend glx --vsync")
--awful.spawn.with_shell("picom backend glx vsync")
--
-- local assignmeent test suit
--
local term = require("plterm")
local sourcei, targeti = positions[sourceunits], positions[targetunits]
local start, finish, inc = tonumber(arg[1]), tonumber(arg[2]), tonumber(arg[3])
local fact = function(n)
	if n == 0 then
		return 1
	else
		return n * fact(n - 1) -- buggy
	end
end
--
-- function test suit
--
local function fact(n)
	if n == 0 then
		return 1
	else
		return n * fact(n - 1)
	end
end
function Lib.foo(x, y)
	return x + y
end
f = function()
	return "x", "y", "z" -- return 3 values
end
--
-- while loop test suit
--
while a[i] do
	print(a[i])
	i = i + 1
end
while useranswer ~= answer do
	io.write("What is 3 + 2? ")
	useranswer = io.read()
end
--
-- for loop test suit
--
for i, v in ipairs(x_values) do
	x_values[i] = math.log(v)
	y_values[i] = math.log(y_values[i])
end

for Key, Kyp, Val, Vyp in lp.db:urows("SELECT Key,Kyp,Val,Vyp FROM luat where TID='tid1'") do
	print(Key, Kyp, Val, Vyp)
end

for i = 1, width do
	num, rem = math.modf(num / 2)
	fl[#fl + 1] = rem >= 0.5
end

for i = 1, a.n do
	if a[i] == value then
		found = i -- save value of `i'
		break
	end
end
--
--
-- repeat loop test suit
--
repeat
	print(j)
	j = j - 1
until j <= 13
--math.floor( (iStart+iEnd)/2 )
--mult = 10^numDecimalPlaces
--layout.display_item = menu_item
--sum = sum + (vm * vm)
--terminal_open()
--counts[v] = 1
--pattern = string.format("([^%s]+)", sep)
--local entry = diriters[#diriters]()
--w = {x=0, y=0, label="console"}
--if (lo < 0) == (p[i-1] < 0) then
--  lo = lo * 2         -- |lo| = 1/2 ULP
--  hi = x + lo         -- -> x off 1 ULP
--  if lo == hi - x then x = hi end
--end
--print "Hello World"
--a = {foo0()}
--type1, type2 = type(op1), type(op2)
--local tmp = self[i + diff] + other[i] + carry
--local abc = {5,12,1}
--local result = {}
--local def = table.clone(abc)
--table.sort(def)
--print(abc[2], def[2]) -- 12	5
--f{x=10, y=20}
--
--
--function factorial_helper(i, acc)
--  if i == 0 then
--    return acc
--  end
--  return factorial_helper(i-1, acc*i)
--end
--
--function factorial(x)
--  return factorial_helper(x, 1)
--end
--  term.color(term.colors.normal)
--function update_display()
--  local screen_col = (layout.max_col - layout.menu_max_str_len)//2
--  local screen_row = ((layout.max_row - 2) - #layout.display_item)//2
--  --print("start column : ", screen_col)
--
--  if screen_col <= 0 then screen_col = 1 end
--  if screen_row < 0 then screen_row = 0 end
--
--  for i = layout.start_row, #layout.display_item do
--  --  term.outf(string.format("selected[%d]", selected))
--    if (i + 1 - layout.start_row) >= layout.max_row - 1 then break end
--    term.golc(screen_row + i + 1 - layout.start_row, screen_col)
--    if  layout.selected == i then
--      term.color(term.colors.green)
--    else
--      term.color(term.colors.normal)
--    end
--    term.outf(string.format("[%d] %s", i, layout.display_item[i]))
--  end
--  term.color(term.colors.normal)
--  -- output prompt
--  screen_col = (layout.max_col - string.len(layout.prompt))/2
--  if screen_col <= 0 then screen_col = 1 end
--  term.golc(screen_row + #layout.display_item+2, screen_col)
--  term.cleareol()
--  term.outf(layout.prompt)
--end
--function layout.input_loop()
--  local ret = 0
--  terminal_open()
--  update_display()
--  local input_ready = term.input()
--  while true do
--    local code = input_ready()
--    term.cleareol()
--    process_input(code)
--    if input_validate(code) then
--      layout.selected = code
--      break
--    end
--    -- return key
--    if tonumber(code) == 13  then
--      local s = layout.input
--      --[
--      if string.len(s) > 0 and tonumber(s) <= #layout.display_item then
--        layout.selected = tonumber(s)
--      end
--      --]]
--      break
--    end
--  end
--  terminal_close()
--  return layout.selected
--end
--function process_input(key)
--  term.golc(layout.max_row, 2)
--
--  -- key up
--  if key == 0xffed then
--    -- term.outf("key is up")
--    if layout.selected > 1 then layout.selected = layout.selected - 1 end
--    if layout.selected < layout.start_row then
--      layout.start_row = layout.selected
--    end
--    layout.input = tostring(layout.selected)
--   -- key down
--  elseif key == 0xffec then
--    -- term.outf("key is down")
--    if layout.selected < #layout.display_item then layout.selected = layout.selected + 1 end
--    if (layout.selected - layout.start_row) >= layout.max_row - 2 then
--      layout.start_row =  layout.start_row + 1
--    end
--    layout.input = tostring(layout.selected)
--  end
--
--  term.clear()
--  update_display()
--
--  -- back space
--  if key == 0x7f then
--    local s = layout.input
--    if (string.len(s) > 0) then
--      layout.input = string.sub(s, 1, string.len(s) - 1)
--    end
--  end
--  if key >= string.byte('1') and key <= string.byte(tostring(#layout.display_item)) then
--    layout.input = layout.input .. term.keyname(key)
--  end
--  term.outf(layout.input)
--end
--
--function terminal_open()
--  term.clear()
--  mode = term.savemode()
--  term.setrawmode() -- required to enable getcurpos()
--
--  layout.max_row, layout.max_col = term.getscrlc()
--end
--
--function terminal_close()
--  term.golc(layout.max_row, 1)
--  term.restoremode(mode)
--end
----]]
--
--return layout
--
--
